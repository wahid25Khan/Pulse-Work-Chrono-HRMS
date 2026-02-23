import os
import re

lwc_dir = 'force-app/main/default/lwc'

for root, dirs, files in os.walk(lwc_dir):
    for file in files:
        if file.endswith('.html'):
            filepath = os.path.join(root, file)
            with open(filepath, 'r') as f:
                content = f.read()
            
            # Replace exactly class="content"
            new_content = re.sub(r'class="content"', 'class="content container-fluid pt-2 ps-2 pe-3 pb-0"', content)
            
            # Replace exactly class="content container-fluid"
            new_content = re.sub(r'class="content container-fluid"', 'class="content container-fluid pt-2 ps-2 pe-3 pb-0"', new_content)
            
            if new_content != content:
                with open(filepath, 'w') as f:
                    f.write(new_content)
                print(f"Updated {filepath}")
