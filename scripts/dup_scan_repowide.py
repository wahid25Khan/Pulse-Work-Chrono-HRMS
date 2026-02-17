import json
import re
import itertools
import difflib
from pathlib import Path

root = Path('.')
include_suffixes = {'.cls', '.js', '.html', '.css', '.xml', '.md'}
exclude_dirs = {'.git', 'node_modules', '.venv', '.sfdx', '.sf', '.scannerwork'}

files = []
for path in root.rglob('*'):
    if not path.is_file():
        continue
    if any(part in exclude_dirs for part in path.parts):
        continue
    if path.suffix.lower() in include_suffixes:
        files.append(path)

comment_patterns = [
    (re.compile(r'/\*.*?\*/', re.S), ' '),
    (re.compile(r'//.*?$', re.M), ' '),
    (re.compile(r'<!--.*?-->', re.S), ' '),
]


def normalize(path: Path) -> str:
    text = path.read_text(encoding='utf-8', errors='ignore')
    for pattern, replacement in comment_patterns:
        text = pattern.sub(replacement, text)
    return re.sub(r'\s+', ' ', text).strip().lower()


items = []
for path in files:
    normalized = normalize(path)
    items.append({'path': path.as_posix(), 'norm': normalized, 'len': len(normalized)})

# exact duplicates
by_content = {}
for item in items:
    by_content.setdefault(item['norm'], []).append(item['path'])
exact_groups = [group for group in by_content.values() if len(group) > 1]
exact_groups.sort(key=lambda group: (-len(group), group[0]))

# near duplicates
near_pairs = []
filtered_items = [item for item in items if item['len'] >= 180]
for left, right in itertools.combinations(filtered_items, 2):
    left_len = left['len']
    right_len = right['len']
    if min(left_len, right_len) / max(left_len, right_len) < 0.55:
        continue
    score = difflib.SequenceMatcher(None, left['norm'], right['norm']).ratio()
    if score >= 0.90:
        near_pairs.append({
            'score': round(score, 4),
            'a': left['path'],
            'b': right['path'],
            'lenA': left_len,
            'lenB': right_len,
        })
near_pairs.sort(key=lambda item: item['score'], reverse=True)

result = {
    'counts': {
        'files': len(items),
        'exact_groups': len(exact_groups),
        'near_pairs': len(near_pairs),
    },
    'exact_groups_top': exact_groups[:30],
    'near_pairs_top': near_pairs[:80],
}

output = Path('docs/reviews/duplicate_scan_repowide.json')
output.write_text(json.dumps(result, indent=2), encoding='utf-8')
print(output.as_posix())
print(json.dumps(result['counts']))
