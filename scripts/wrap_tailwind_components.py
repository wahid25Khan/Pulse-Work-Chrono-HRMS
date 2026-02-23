import os
import re

lwc_dir = 'force-app/main/default/lwc'

components_to_wrap = [
    'pwchronoDashboard',
    'pwchronoSalarySlipViewer',
    'pwchronoShiftRosterView'
]

for comp in components_to_wrap:
    filepath = os.path.join(lwc_dir, comp, f"{comp}.html")
    if os.path.exists(filepath):
        with open(filepath, 'r') as f:
            content = f.read()
        
        if 'class="page-wrapper"' not in content:
            # Wrap the content inside <template> with page-wrapper and content
            # This is a bit tricky because of multiple templates.
            # Let's just do it manually for pwchronoDashboard
            pass
