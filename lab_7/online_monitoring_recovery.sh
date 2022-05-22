#!/bin/bash

# Запускать после(в разных консолях. одновременная работа) с файлом recovery.sh
# Он нужен для того чтобы отслеживать существование сигнального файла recovery.signal
# Даем на мониторинг восстановления базы 20 минут( можно увеличить-уменьшить в зависимости от размера БД )
# Как только recovery.signal удалится это будет означать что БД восстановлена
# Иначе падаем с ошибкой


CHECK_RECOVERY_SIGNAL_ITER=0
while [ ${CHECK_RECOVERY_SIGNAL_ITER} -le 120 ]
do
    if [ ! -f "/var/lib/postgresql/12/main/recovery.signal" ]
    then
        echo "recovery.signal removed"
        break
    fi
    sleep 10
    ( (CHECK_RECOVERY_SIGNAL_ITER+1) )
done

if [ -f "/var/lib/postgresql/12/main/recovery.signal" ]
then
    echo "recovery.signal still exists!"
    exit 17
fi

# Проверим целостность данных, но без проверки индексов
if ! su - postgres -c 'pg_dumpall > /dev/null'
then
    echo 'pg_dumpall failed'
    exit 125
fi
