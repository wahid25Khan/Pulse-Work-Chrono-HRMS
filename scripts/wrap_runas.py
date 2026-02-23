import re

with open('force-app/main/default/classes/PWChrono_AuthController_Test.cls', 'r') as f:
    content = f.read()

# Find all @IsTest methods
pattern = re.compile(r'(@IsTest\s+static\s+void\s+\w+\(\)\s*\{)([\s\S]*?)(\n  \})')

def replacer(match):
    method_start = match.group(1)
    method_body = match.group(2)
    method_end = match.group(3)
    
    # If already wrapped, skip
    if 'System.runAs' in method_body:
        return match.group(0)
        
    # Indent the body
    indented_body = '\n'.join(['    ' + line if line else line for line in method_body.split('\n')])
    
    new_body = f"{method_start}\n    System.runAs(new User(Id = UserInfo.getUserId())) {{{indented_body}\n    }}{method_end}"
    return new_body

new_content = pattern.sub(replacer, content)

with open('force-app/main/default/classes/PWChrono_AuthController_Test.cls', 'w') as f:
    f.write(new_content)
