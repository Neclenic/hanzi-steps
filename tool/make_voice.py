"""Makes the natural-voice recordings in assets/voice with Azure neural text-to-speech.

Run from the project folder:  python3 tool/make_voice.py
It finds the Chinese text in lib/ (every all-Chinese string, plus the "all four tones" lines of the
pinyin chart), records each one that has no recording yet, and rewrites assets/voice/index.txt.
Text the app builds while running (story paragraphs joined together and so on) can be added by
listing it, one per line, in a file passed with --extra.

It needs network access to swedencentral.api.cognitive.microsoft.com (with the Azure Speech key
sent as the Ocp-Apim-Subscription-Key header, for example as a network secret of the cloud
environment) and to swedencentral.tts.speech.microsoft.com. The key is never stored in the project.
"""
import argparse, glob, hashlib, html, os, re, time, urllib.error, urllib.request

REGION = 'swedencentral'
VOICE = 'zh-CN-XiaoxiaoNeural'
FORMAT = 'audio-24khz-48kbitrate-mono-mp3'
OUT = 'assets/voice'

CJK = re.compile(r'[一-鿿]')
ONLY_CHINESE = re.compile(r'^[一-鿿　-〿＀-￯‘’“” …·—\-]+$')
# Listening clips (lib/data/listening.dart): speaker A is a woman, B a man.
VOICES = {'A': 'zh-CN-XiaoxiaoNeural', 'B': 'zh-CN-YunxiNeural'}


def clip_name(text):
    """Must match clipName() in lib/logic/speech.dart."""
    return hashlib.sha1(re.sub(r'\s', '', text).encode()).hexdigest()[:12]


def find_texts(extra=None):
    texts = set()
    for f in glob.glob('lib/**/*.dart', recursive=True):
        src = open(f, encoding='utf-8').read()
        for m in re.finditer(r"'((?:[^'\\\n]|\\.)*)'|\"((?:[^\"\\\n]|\\.)*)\"", src):
            t = m.group(1) or m.group(2) or ''
            if '$' not in t and CJK.search(t) and ONLY_CHINESE.match(t):
                texts.add(t)
    chart = open('lib/data/pinyin_chart.dart', encoding='utf-8').read()
    for m in re.finditer(r"^  '(\w+)': \[(.*)\],$", chart, re.M):
        texts.add('，'.join(re.findall(r"\('(.)',", m.group(2))))
    if extra:
        texts.update(l.strip() for l in open(extra, encoding='utf-8') if CJK.search(l))
    return sorted({re.sub(r'\s', '', t) for t in texts})


class Azure:
    def __init__(self):
        self.token, self.at = None, 0

    def _token(self):
        if not self.token or time.time() - self.at > 480:
            req = urllib.request.Request(f'https://{REGION}.api.cognitive.microsoft.com/sts/v1.0/issueToken',
                                         data=b'', method='POST')
            self.token, self.at = urllib.request.urlopen(req, timeout=30).read().decode(), time.time()
        return self.token

    def record(self, text=None, ssml=None):
        ssml = ssml or f"<speak version='1.0' xml:lang='zh-CN'><voice name='{VOICE}'>{html.escape(text)}</voice></speak>"
        for attempt in range(8):
            try:
                req = urllib.request.Request(
                    f'https://{REGION}.tts.speech.microsoft.com/cognitiveservices/v1', data=ssml.encode(),
                    method='POST', headers={'Authorization': 'Bearer ' + self._token(),
                                            'Content-Type': 'application/ssml+xml',
                                            'X-Microsoft-OutputFormat': FORMAT, 'User-Agent': 'hanzi-steps'})
                return urllib.request.urlopen(req, timeout=60).read()
            except urllib.error.HTTPError as e:
                if e.code == 401:
                    self.token = None
                wait = int(e.headers.get('Retry-After') or 0) or min(60, 2 ** attempt)
                print(f'HTTP {e.code}, waiting {wait}s', flush=True)
                time.sleep(wait)
            except OSError as e:
                print('Network error:', e, flush=True)
                time.sleep(5)
        raise RuntimeError(f'Could not record {text}')


def find_listening():
    """The listening clips in lib/data/listening.dart, as (id, [(speaker, text)])."""
    src = open('lib/data/listening.dart', encoding='utf-8').read()
    out = []
    for part in re.split(r"\n  ListenClip\(", src)[1:]:
        cid = re.match(r"'([\w-]+)'", part).group(1)
        out.append((cid, re.findall(r"_L\('([AB])', '([^']+)'", part)))
    return out


def listening_ssml(lines):
    parts = [f"<voice name='{VOICES[s]}'>{html.escape(t)}<break time='350ms'/></voice>" for s, t in lines]
    return "<speak version='1.0' xml:lang='zh-CN'>" + ''.join(parts) + '</speak>'


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--extra', help='a file with more text to record, one per line')
    ap.add_argument('--list', action='store_true', help='only show what would be recorded')
    args = ap.parse_args()
    texts = find_texts(args.extra)
    os.makedirs(OUT, exist_ok=True)
    todo = [t for t in texts if not os.path.exists(f'{OUT}/{clip_name(t)}.mp3')]
    print(f'{len(texts)} texts, {len(todo)} to record', flush=True)
    if args.list:
        print('\n'.join(todo))
        return
    azure = Azure()
    # Listening clips are recorded whole, at natural speed, with a voice for each speaker.
    for cid, lines in find_listening():
        path = f'{OUT}/listen-{cid}.mp3'
        if not os.path.exists(path):
            open(path + '.tmp', 'wb').write(azure.record(ssml=listening_ssml(lines)))
            os.replace(path + '.tmp', path)
            print('Recorded listening clip', cid, flush=True)
    for i, t in enumerate(todo, 1):
        data = azure.record(t)
        path = f'{OUT}/{clip_name(t)}.mp3'
        open(path + '.tmp', 'wb').write(data)
        os.replace(path + '.tmp', path)
        if i % 100 == 0:
            print(f'{i} of {len(todo)}', flush=True)
    # The index lists every recording in the folder, so the app knows what it can play.
    names = sorted(f[:-4] for f in os.listdir(OUT) if f.endswith('.mp3'))
    open(f'{OUT}/index.txt', 'w').write('\n'.join(names) + '\n')
    print(f'Done: {len(names)} recordings', flush=True)


if __name__ == '__main__':
    main()
