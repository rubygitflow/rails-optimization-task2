**Origial project** https://github.com/hardcode-dev/rails-optimization-task2

### Note
*Для работы скрипта требуется Ruby 2.4+*

# Задание №2
В этом задании нужно оптимизировать программу из первого задания, но теперь с фокусом на оптимизацию памяти.

## Бюджет
Программа не должна потреблять больше **70Мб** памяти при обработке файла `data_large` в течение всей своей работы.

## Подсказки
Из бюджета очевидно, что мы не можем ни считывать файл в память целиком, ни накапливать в памяти данные по пользователям.

Значит, программу нужно переосмыслить и написать в "потоковом" стиле - когда мы читаем исходный файл строку за строкой и сразу же на ходу пишем файл с результатами.

На этот раз для прохождения теста достаточно, чтобы результат совпадал с эталоном как `json`-объект, а не строка. То есть порядок полей в объекте не важен.

Можем считать, что все сессии юзера всегда идут одним непрерывным куском. Нет такого, что сначала идёт часть сессий юзера, потом сессии другого юзера, и потом снова сессии первого.


## План работы
В этот раз переработка потребуется кардинальная, так что нужно сделать два этапа

- перевести программу на потоковый подход так чтобы она прошла тесты
- профилировать получившуюся программу рассмотренными инструментами и оптимизировать память ещё сильнее, сделать две-три итерации по фреймворку оптимизации и написать `case-study`
- когда закончите, сделайте замер времени работы программы; получилось ли быстрее чем при оптимизации по процессору в первом задании?


## Как измерять кол-во использованной памяти
В фидбек-лупе можно получать кол-во памяти *в конце* выполнения программы:

```ruby
puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)"
```

После успешной оптимизации дополнительно нужно профилировать программу с помощью `valgrind massif visualizer` и проверить, что память укладывается в бюджет не только в конце работы программы, но и в течение вообще всего времени работы.

## Сдача задания
Для сдачи задания нужно форкнуть этот проект, сделать `PR` в него и прислать ссылку для проверки.

В `PR`
- должны быть внесены оптимизации в `task-2.rb`;
- должен быть файл `case-study.md` с описанием проделанной оптимизации;
- в описании должен быть скриншот из `valgrind massif visualizer`, на котором видно, что программа укладывается в бюджет на протяжении всего времени исполнения;
- в описание `PR` добавьте чеклист и отметьте, что из него сделали; для получения максимальной пользы надо отметить всё.

## Checklist
- [ ] Построить и проанализировать отчёт гемом `memory_profiler`
- [ ] Построить и проанализировать отчёт `ruby-prof` в режиме `Flat`;
- [ ] Построить и проанализировать отчёт `ruby-prof` в режиме `Graph`;
- [ ] Построить и проанализировать отчёт `ruby-prof` в режиме `CallStack`;
- [ ] Построить и проанализировать отчёт `ruby-prof` в режиме `CallTree` c визуализацией в `QCachegrind`;
- [ ] Построить и проанализировать текстовый отчёт `stackprof`;
- [ ] Построить и проанализировать отчёт `flamegraph` с помощью `stackprof` и визуализировать его в `speedscope.app`;
- [ ] Построить график потребления памяти в `valgrind massif visualier` и включить скриншот в описание вашего `PR`;
- [ ] Написать тест, на то что программа укладывается в бюджет по памяти

Не нужно включать в `PR` выводы всех этих отчётов, просто используйте каждый хотя бы по разу в вашем `Case-study`.

## Формат шагов case-study
Каждый шаг оптимизации в `case-study` должен содержать четыре составляющих:
- какой отчёт показал главную точку роста
- как вы решили её оптимизировать
- как изменилась метрика
- как изменился отчёт профилировщика

## Заметки
- Не отключайте GC при вычислении метрики
- Отключайте профилировщик при вычислении метрики
- Используйте все описанные инструменты и отчёты хотя бы по разу – научитесь с ними работать!
- Вкладывайтесь в удобство разработки и скорость фидбек-лупа!
