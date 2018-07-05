# Инструкция по подключению к удаленному Git.
 
## Зарегистрироваться в GitLab через сайт (обязательно)

1. Зайти на адрес https://owa.nsd.ru/gitlab/
2. Откроется окно аутентификации ForeFront
3. Ввести свои доменные логин и пароль
4. Откроется окно аутентификации GitLab
5. Ввести свои доменные логин и пароль
6. GitLab найдет учетные данные в Active Directory и создаст симметрично пользователя у себя, после этого можно будет пользоваться функциональностью git
7. Откроется домашняя страница GitLab
 
# Поднять локальный прокси.

Цель действия: git не может обойти аутентификацию ForeFront. Чтобы ее обойти на локальную машину пользователя ставится утилита owa_proxy, дальнейшее взаимодействие осуществляется по цепочке: Пользователь <-> утилита git <-> nsd_gitlab_proxy <-> https://owa.nsd.ru <-> GitLab

1. Скачать и установить Strawberry Perl http://strawberryperl.com/
2. Установить пакеты WWW::Mechanize, HTTP::Daemon

    - cpan
    - install WWW::Mechanize
    - install HTTP::Daemon
    - quit
 
3. Запустить утилиту: perl nsd_gitlab_proxy.pl доменный\_логин доменный\_пароль порт. Например для пользователя mikhailov с паролем 12345 поднять прокси на порту 3128:

    perl nsd_gitlab_proxy.pl mikhailov 12345 3128
 
4. Утвердительно ответить, если Windows спросит предоставлять ли доступ утилите nsd_gitlab_proxy к сети
 
5. Запустить команды
    - mkdir owa_test (создаем пустую папку)
    - cd owa_test (переходим в папку)
    - git init (инициализируем пустой репозиторий)
    - git config --global http.proxy http://owa.nsd.ru.proxy localhost:3128  
        (данная команда сообщает git ходить к GitLab через локальный прокси поднятый на порту 3128 для всех репозиториев GitLab)
    - git remote add origin http://owa.nsd.ru/gitlab/mikhailov/owa_test.git  
        (сообщаем git где находится удаленный репозиторий. Обратите внимание – протокол HTTP, это важно. nsd_gitlab_proxy сам заменит http на https)
    - git pull -u origin master  
        (тянем к себе репозиторий)
