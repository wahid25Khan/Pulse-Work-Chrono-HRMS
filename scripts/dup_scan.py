import json
import re
import itertools
import difflib
from pathlib import Path

ROOT = Path('force-app/main/default')
APEX_FILES = sorted((ROOT / 'classes').glob('*.cls'))
PROD_APEX = [p for p in APEX_FILES if not p.name.endswith('_Test.cls')]
LWC_FILES = sorted(
    [
        p
        for p in (ROOT / 'lwc').rglob('*')
        if p.is_file() and p.suffix in {'.js', '.html', '.css', '.xml'}
    ]
)
LWC_SOURCE_FILES = sorted(
    [
        p
        for p in (ROOT / 'lwc').rglob('*')
        if p.is_file() and p.suffix in {'.js', '.html', '.css'}
    ]
)

COMMENT_PATTERNS = [
    (re.compile(r'/\*.*?\*/', re.S), ' '),
    (re.compile(r'//.*?$', re.M), ' '),
    (re.compile(r'<!--.*?-->', re.S), ' '),
]


def normalize(path: Path) -> str:
    text = path.read_text(encoding='utf-8', errors='ignore')
    for pattern, replacement in COMMENT_PATTERNS:
        text = pattern.sub(replacement, text)
    return re.sub(r'\s+', ' ', text).strip().lower()


def exact_duplicates(files):
    by_hash = {}
    for path in files:
        normalized = normalize(path)
        key = normalized
        by_hash.setdefault(key, []).append(path.as_posix())
    groups = [group for group in by_hash.values() if len(group) > 1]
    groups.sort(key=lambda g: (len(g), g[0]), reverse=True)
    return groups


def near_duplicates(files, threshold, min_len=200):
    items = []
    for path in files:
        normalized = normalize(path)
        if len(normalized) >= min_len:
            items.append((path.as_posix(), normalized, len(normalized)))

    pairs = []
    for (a_path, a_text, a_len), (b_path, b_text, b_len) in itertools.combinations(items, 2):
        if min(a_len, b_len) / max(a_len, b_len) < 0.5:
            continue
        score = difflib.SequenceMatcher(None, a_text, b_text).ratio()
        if score >= threshold:
            pairs.append(
                {
                    'score': round(score, 4),
                    'a': a_path,
                    'b': b_path,
                    'lenA': a_len,
                    'lenB': b_len,
                }
            )

    pairs.sort(key=lambda item: item['score'], reverse=True)
    return pairs


def main():
    result = {
        'counts': {
            'apex_all': len(APEX_FILES),
            'apex_prod': len(PROD_APEX),
            'lwc_all': len(LWC_FILES),
            'lwc_source': len(LWC_SOURCE_FILES),
        },
        'apex_exact': exact_duplicates(PROD_APEX),
        'apex_near': near_duplicates(PROD_APEX, threshold=0.72),
        'lwc_exact_all': exact_duplicates(LWC_FILES),
        'lwc_exact_source': exact_duplicates(LWC_SOURCE_FILES),
        'lwc_near_source': near_duplicates(LWC_SOURCE_FILES, threshold=0.83),
    }

    out = Path('docs/reviews/duplicate_scan_focus.json')
    out.write_text(json.dumps(result, indent=2), encoding='utf-8')
    print(out.as_posix())


if __name__ == '__main__':
    main()
