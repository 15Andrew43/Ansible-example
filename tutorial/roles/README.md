## Example-8 (Roles)

 - ansible-galaxy init deploy_apache_web


### Structure of directories
```
.
├── README.md
└── deploy_apache_web
    ├── README.md
    ├── defaults
    │   └── main.yml
    ├── files
    ├── handlers
    │   └── main.yml
    ├── meta
    │   └── main.yml
    ├── tasks
    │   └── main.yml
    ├── templates
    ├── tests
    │   ├── inventory
    │   └── test.yml
    └── vars
        └── main.yml
```



Распилим playbook.yml по этим файликам
### playbook.yml
```
---
- name: Install Apache and upload my Web page
  hosts: all
  become: yes

  vars:
    source_folder: ./MyWebSite2
    destin_folder: /var/www/html

  tasks:
  - name: Check and Print LINUX Version
    debug: var=ansible_os_family

  - block: # ====== block for RedHat ==========

      - name: Install Apache WebServer for RedHat
        yum: name=httpd state=latest                     # <-------------

      - name: Start Apache and enable it on the every boot for RedHat
        service: name=httpd state=started enabled=yes    # <-------------
        
    when: ansible_os_family == "RedHat"

  - block: # ====== block for ubuntu ===========

      - name: Install Apache WebServer for Debian
        apt: name=apache2 state=latest                   # <-------------

      - name: Start Apache and enable it on the every boot for Debian
        service: name=apache2 state=started enabled=yes  # <-------------
        
    when: ansible_os_family != "RedHat"


  - name: Generate index.html file
    template: src={{ source_folder }}/index.j2 dest={{ destin_folder }}/index.html mode=0555
    notify: 
        - Restart Apache RedHat
        - Restart Apache Debian

  - name: copy my HomePage to servers
    copy: src={{ source_folder }}/{{ item }} dest = {{ destin_folder }} mode=0555
#   with_fileglob: "{{ source_folder }}/*.*"
    loop:
        - "bahamas.png"
        - "bulgaria.png"
        - "jordan.png"
        - "newzeland.png"
    notify: 
        - Restart Apache RedHat
        - Restart Apache Debian

  handlers:
  - name: Restart Apache RedHat
    service: name=httpd state=restarted
    when: ansible_os_family == "RedHat"
  - name: Restart Apache Debian
    service: name=apache2 state=restarted
    when: ansible_os_family != "RedHat"
```


### New Structure of directories
```
.
├── README.md
└── deploy_apache_web
    ├── README.md
    ├── defaults
    │   └── main.yml
    ├── files
    │   ├── bahamas.png
    │   ├── jordan.png
    │   ├── newzeland.png
    │   └── bulgaria.png
    ├── handlers
    │   └── main.yml
    ├── meta
    │   └── main.yml
    ├── tasks
    │   └── main.yml
    ├── templates
    │   └── index.j2
    ├── tests
    │   ├── inventory
    │   └── test.yml
    └── vars
        └── main.yml
```


### defaults/main.yml
```
destin_folder: /var/www/html
```
### hadlers/main.yml
```
- name: Restart Apache RedHat
  service: name=httpd state=restarted
  when: ansible_os_family == "RedHat"
- name: Restart Apache Debian
  service: name=apache2 state=restarted
  when: ansible_os_family != "RedHat"
```
### tasks/main.yml
```
- name: Check and Print LINUX Version
  debug: var=ansible_os_family

- block: # ====== block for RedHat ==========

    - name: Install Apache WebServer for RedHat
      yum: name=httpd state=latest                     # <-------------

    - name: Start Apache and enable it on the every boot for RedHat
      service: name=httpd state=started enabled=yes    # <-------------
      
  when: ansible_os_family == "RedHat"

- block: # ====== block for ubuntu ===========

    - name: Install Apache WebServer for Debian
      apt: name=apache2 state=latest                   # <-------------

    - name: Start Apache and enable it on the every boot for Debian
      service: name=apache2 state=started enabled=yes  # <-------------
      
  when: ansible_os_family != "RedHat"


- name: Generate index.html file
  template: src=index.j2 dest={{ destin_folder }}/index.html mode=0555
  notify: 
      - Restart Apache RedHat
      - Restart Apache Debian

- name: copy my HomePage to servers
  copy: {{ item }} dest = {{ destin_folder }} mode=0555
#   with_fileglob: "{{ source_folder }}/*.*"
  loop:
      - "bahamas.png"
      - "bulgaria.png"
      - "jordan.png"
      - "newzeland.png"
  notify: 
      - Restart Apache RedHat
      - Restart Apache Debian
```


### playbook.yml
```
---
- name: Install Apache and upload my Web page
  hosts: all
  become: yes

  roles:
    - { role: deploy_apache_web, when: ansible_system == "Linux" }
```



