# Практика с SELinux
## Цель: Тренируем умение работать с SELinux: диагностировать проблемы и модифицировать политики SELinux для корректной работы приложений, если это требуется.
### Запустить nginx на нестандартном порту 3-мя разными способами:  
- переключатели setsebool;  
- добавление нестандартного порта в имеющийся тип;  
- формирование и установка модуля SELinux.  

### Введение.  
Сформирована виртуальная машина средствами Vagrant, с помощью директивы SHELL установлены пакеты:  
policycoreutils-python policycoreutils-devel policycoreutils-newrole policycoreutils-restorecond setools-console
и nginx.
