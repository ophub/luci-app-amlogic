<div align="center">
    <img src="https://github.com/user-attachments/assets/455ec33b-5a00-4881-9bb4-10d4aba42e89" alt="luci-app-amlogic" />
</div>

# luci-app-amlogic / Сервис Amlogic

[English Instructions](README.md) | [中文说明](README.cn.md) | [Инструкция на русском](README.ru.md)

Плагин поддерживает онлайн-управление устройствами серии Amlogic S9xxx (X96, HK1, H96 и др.), Allwinner (V-Plus Cloud) и Rockchip (BeikeYun, Chainedbox-L1-Pro, FastRhino-R66S/R68S, Radxa-5B/E25). Также поддерживается использование в OpenWrt, установленном в KVM-виртуальных машинах под управлением системы Armbian. Текущие функции включают `установку OpenWrt на eMMC`, `ручную загрузку / онлайн-обновление` прошивки или версии ядра OpenWrt, `резервное копирование / восстановление конфигурации`, `управление снимками состояния (снапшотами)`, а также `настройку адресов загрузки прошивки и ядра`.

Для работы системы OpenWrt с плагином Amlogic Service на устройстве необходима поддержка определённых [обязательных пакетов](https://github.com/ophub/amlogic-s9xxx-openwrt/blob/main/documents/README.md#1011-required-openwrt-options). При `пользовательской сборке OpenWrt` добавьте их согласно инструкции. При `ручной установке` через скрипт в OpenWrt без предустановленного плагина — если выводится сообщение об отсутствующих зависимостях, установите их по указаниям журнала (`Система` > `Пакеты` > `Обновить список` > `Найти нужный пакет` > `Установить`), затем `повторите попытку`.

## Ручная установка

- Если в используемой вами системе OpenWrt этот плагин отсутствует, его можно установить вручную. Войдите в систему OpenWrt по SSH и перейдите в любой каталог, либо откройте `Меню системы` → `TTYD Terminal`, затем выполните следующую команду для автоматической загрузки и установки плагина.

```yaml
# Автоматически выбрать доступную версию плагина (рекомендуется)
curl -fsSL ophub.org/luci-app-amlogic | bash
# Загрузить версию плагина на Lua (ветка lua)
curl -fsSL ophub.org/luci-app-amlogic | bash -s -- -b lua
# Загрузить версию плагина на JavaScript (ветка main)
curl -fsSL ophub.org/luci-app-amlogic | bash -s -- -b main
```

или

```yaml
# Автоматически выбрать доступную версию плагина (рекомендуется)
curl -fsSL git.io/luci-app-amlogic | bash
# Загрузить версию плагина на Lua (ветка lua)
curl -fsSL git.io/luci-app-amlogic | bash -s -- -b lua
# Загрузить версию плагина на JavaScript (ветка main)
curl -fsSL git.io/luci-app-amlogic | bash -s -- -b main
```

## Компиляция плагина

```shell
# Добавить плагин
rm -rf package/luci-app-amlogic
git clone -b main https://github.com/ophub/luci-app-amlogic.git package/luci-app-amlogic

# Можно скомпилировать плагин отдельно
make package/luci-app-amlogic/compile V=99

# Или включить плагин при полной сборке OpenWrt
make menuconfig
# choose LuCI ---> 3. Applications  ---> <*> luci-app-amlogic ----> save
make V=99
```

## Пользовательская настройка

- Плагин поддерживает прошивки OpenWrt, упакованные скриптами [flippy](https://github.com/unifreq/openwrt_packit) и [ophub](https://github.com/ophub/amlogic-s9xxx-openwrt). Адреса загрузки файлов `прошивки OpenWrt` и `ядра` в функции `Онлайн-загрузка и обновление` можно настроить на собственный репозиторий GitHub. Настройки хранятся в файле [/etc/config/amlogic](luci-app-amlogic/root/etc/config/amlogic). При сборке прошивки OpenWrt можно изменить соответствующие значения напрямую в этом файле:

```shell
# 1. Указать репозиторий для загрузки файлов OpenWrt
sed -i "s|amlogic_firmware_repo.*|amlogic_firmware_repo 'https://github.com/USERNAME/REPOSITORY'|g" package/luci-app-amlogic/root/etc/config/amlogic

# 2. Указать ключевое слово тегов в Releases
sed -i "s|ARMv8|RELEASES_TAGS_KEYWORD|g" package/luci-app-amlogic/root/etc/config/amlogic

# 3. Указать расширение файлов OpenWrt в Releases
sed -i "s|.img.gz|.OPENWRT_SUFFIX|g" package/luci-app-amlogic/root/etc/config/amlogic

# 4. Указать путь для загрузки ядра OpenWrt
sed -i "s|amlogic_kernel_path.*|amlogic_kernel_path 'https://github.com/USERNAME/REPOSITORY'|g" package/luci-app-amlogic/root/etc/config/amlogic

# 5. Указать ветку плагина Amlogic Service (main/lua)
sed -i "s|amlogic_plugin_branch.*|amlogic_plugin_branch 'main'|g" package/luci-app-amlogic/root/etc/config/amlogic
```

- При сборке OpenWrt достаточно изменить указанные 4 пункта для пользовательской настройки. Эти параметры также можно изменить после входа в систему OpenWrt через `Система` → `Сервис Amlogic`.

## Описание настроек плагина

Настройки плагина включают 4 раздела: загрузка прошивки OpenWrt, загрузка ядра, выбор ветки версий и дополнительные параметры.

### Раздел загрузки прошивки OpenWrt содержит три параметра

1. Репозиторий загрузки прошивки OpenWrt: укажите адрес GitHub-репозитория, в котором вы компилируете OpenWrt (или репозиторий другого разработчика), например: `https://github.com/breakingbadboy/OpenWrt`. Кнопка `OpenWrt Compiler author` на главной странице плагина будет ссылаться на указанный здесь адрес (ссылка обновляется автоматически), что позволяет пользователям легко найти автора прошивки для общения и совместной работы.

2. Ключевое слово тегов в Releases: данное ключевое слово должно позволять отличать прошивку от образов для других архитектур (x86, R2S и т. д.), чтобы по нему можно было точно найти соответствующую прошивку OpenWrt.

3. Расширение файлов OpenWrt: поддерживаемые форматы — `.img.gz`, `.img.xz` и `.7z`. Формат `.img` не поддерживается из-за большого размера файла и низкой скорости загрузки.

- При именовании файлов прошивки `OpenWrt` в Releases указывайте `модель SoC` и `версию ядра`: openwrt_ `{soc}`_ xxx_`{kernel}`_ xxx.img.gz, например: openwrt_ `s905d`_ n1_R21.8.6_k`5.15.25`-flippy-62+o.7z. Поддерживаемые модели `SoC`: `s905x3`, `s905x2`, `s905x`, `s905w`, `s905d`, `s922x`, `s912`, `l1pro`, `beikeyun`, `vplus`. Поддерживаемые версии ядра: `5.10.xxx`, `5.15.xxx` и другие.

### Раздел загрузки ядра содержит два параметра

- Репозиторий загрузки ядра: можно указать полный URL `https://github.com/ophub/kernel` или сокращённый вариант `ophub/kernel`.

- Теги загрузки ядра: позволяет указать, из какого тега в разделе Releases репозитория ядра следует загружать файлы, например [kernel_flippy](https://github.com/ophub/kernel/releases/tag/kernel_flippy), [kernel_stable](https://github.com/ophub/kernel/releases/tag/kernel_stable), [kernel_rk3588](https://github.com/ophub/kernel/releases/tag/kernel_rk3588) и [kernel_rk35xx](https://github.com/ophub/kernel/releases/tag/kernel_rk35xx). Если тег указан, плагин будет загружать ядро исключительно из него; если поле оставлено пустым, плагин автоматически выберет наиболее подходящий тег на основе параметров текущей системы OpenWrt.

### Выбор ветки версии ядра содержит один параметр

- Установка ветки версии ядра: по умолчанию используется ветка текущей прошивки OpenWrt. Вы можете свободно выбрать другую ветку или задать произвольную, например `6.18`, `6.12` и т. д. Операции `[Онлайн-загрузка и обновление]` для `OpenWrt` и `ядра` будут выполняться в соответствии с выбранной веткой.

### Параметр ветки плагина содержит один параметр

- Ветка плагина Amlogic Service: по умолчанию используется JavaScript-ветка `main`, однако при необходимости её можно изменить на `lua` (Lua) или другую. Данный параметр непосредственно применяется к операции `[Обновить только плагин Amlogic Service]` в разделе `[Онлайн-загрузка и обновление]` — система выполнит загрузку и обновление согласно выбранной ветке. Обратите внимание: ветки main и lua отличаются только используемым языком программирования; по функциональности они полностью идентичны — например, shell-скрипты, задействованные в таких ключевых операциях, как `Установка OpenWrt`, `Обновление ядра` и `Управление снапшотами`, абсолютно одинаковы.

### Дополнительные параметры

- Сохранять конфигурацию при обновлении: настраивается по необходимости. При включении текущая конфигурация будет сохранена во время обновления прошивки.

- Автоматически записывать загрузчик: рекомендуется включить — обеспечивает улучшенную совместимость и поддержку загрузки.

- Тип файловой системы: настраивает тип файловой системы общего раздела (/mnt/mmcblk*p4) при установке OpenWrt (по умолчанию ext4). Параметр применяется только при чистой установке OpenWrt и не изменяет тип файловой системы существующего общего раздела при обновлении ядра или прошивки.

### Описание настроек по умолчанию

- Служба загрузки прошивки OpenWrt по умолчанию для этого плагина ( [Полная версия](https://github.com/breakingbadboy/OpenWrt/releases/tag/ARMv8) | [Мини-версия](https://github.com/breakingbadboy/OpenWrt/releases/tag/armv8_mini) | [Версия от Flippy](https://github.com/breakingbadboy/OpenWrt/releases/tag/flippy_openwrt) ) предоставлена [breakingbadboy](https://github.com/breakingbadboy/OpenWrt). Он является ключевым сопровождающим сообщества Flippy, глубоко разбирается в сборке OpenWrt и прекрасно знаком с установкой и настройкой различных ARM-устройств. Если у вас возникнут вопросы по сборке или использованию OpenWrt, обращайтесь в сообщество или оставляйте отзывы на его странице GitHub.

- Ядро OpenWrt по умолчанию для плагина предоставлено репозиторием [https://github.com/ophub/kernel](https://github.com/ophub/kernel). Ядра под тегом [kernel_flippy](https://github.com/ophub/kernel/releases/tag/kernel_flippy) — это стабильные ядра мейнлайна, скомпилированные и опубликованные разработчиком [flippy](https://github.com/unifreq). В тегах [kernel_rk3588](https://github.com/ophub/kernel/releases/tag/kernel_rk3588) и [kernel_rk35xx](https://github.com/ophub/kernel/releases/tag/kernel_rk35xx) ядра с именем, содержащим `flippy`, — это специализированные ядра для Rockchip от того же разработчика, остальные скомпилированы [ophub/kernel](https://github.com/ophub/kernel). Под тегом [kernel_stable](https://github.com/ophub/kernel/releases/tag/kernel_stable) находятся стабильные ядра мейнлайна от [ophub/kernel](https://github.com/ophub/kernel).

- После окончания жизненного цикла (EOL) ядра устаревают. В этом случае можно выбрать другую поддерживаемую версию ядра в `Настройках плагина`. Если для некоторых версий ядра ещё нет соответствующей полной прошивки, также можно изменить ветку ядра в `Настройках плагина` для соответствия доступной версии из источника загрузки.

## Инструкция по использованию плагина

Плагин предоставляет 6 функций: Установить OpenWrt, Ручная загрузка и обновление, Онлайн-загрузка и обновление, Резервное копирование конфигурации, Настройки плагина и Настройки ЦП.

1. Установить OpenWrt: выберите устройство из списка `Выбор модели устройства` и нажмите `Установить`, чтобы записать прошивку с TF/SD/USB на встроенное хранилище eMMC устройства.

2. Ручная загрузка и обновление: нажмите кнопку `Выбрать файл`, выберите локальное `Ядро OpenWrt (необходимо загрузить полный комплект файлов ядра)` или `Прошивку OpenWrt (рекомендуется сжатый формат)` и загрузите. После завершения загрузки внизу страницы появится соответствующая кнопка `Заменить ядро OpenWrt` или `Обновить прошивку OpenWrt`. Нажмите для выполнения обновления (после завершения система автоматически перезагрузится).

3. Онлайн-загрузка и обновление: нажмите кнопку `Обновить только плагин Amlogic Service`, чтобы обновить плагин до последней версии; нажмите `Обновить только ядро системы`, чтобы загрузить ядро согласно ветке, выбранной в `Настройках плагина`; нажмите `Полное обновление системы`, чтобы загрузить последнюю прошивку с адреса, указанного в `Настройках плагина`. Нажмите кнопку `Восстановить ядро`, чтобы скопировать текущее работающее ядро на целевой диск — это упрощает восстановление в случае, если после неудачного обновления ядра система OpenWrt не загружается. Например, можно загрузить OpenWrt с USB для восстановления системы на eMMC; поддерживается взаимное восстановление между устройствами `eMMC/NVME/sdX`.

4. Резервное копирование конфигурации: нажмите кнопку `Открыть список` для редактирования списка резервного копирования; нажмите `Скачать резервную копию` для сохранения конфигурации OpenWrt на локальный компьютер; нажмите `Загрузить резервную копию` для восстановления конфигурации системы из файла резервной копии. Кнопки `Создать снапшот`, `Восстановить снапшот` и `Удалить снапшот` позволяют управлять снапшотами. Снапшот фиксирует все настройки из каталога `/etc` текущей системы OpenWrt и позволяет в любой момент восстановить сохранённое состояние одним нажатием. По функциональности аналогично `Скачать резервную копию`, однако снапшоты хранятся только на устройстве и не могут быть загружены.

5. Настройки плагина: задайте адрес загрузки ядра и другие параметры плагина — подробнее см. в разделе `Описание настроек плагина`.

6. Настройки ЦП: настройте политику управления ЦП (рекомендуется использовать настройки по умолчанию) в соответствии с потребностями.

Примечание: некоторые функции, такие как `Установить OpenWrt` и `Настройки ЦП`, автоматически скрываются в зависимости от типа устройства и условий работы.

## Инструкция по использованию в KVM-виртуальной машине

На устройствах с достаточной производительностью можно сначала установить систему [Armbian](https://github.com/ophub/amlogic-s9xxx-armbian), а затем использовать KVM-виртуальные машины для параллельной работы нескольких систем. Образ системы OpenWrt можно создать с помощью скрипта [mk_qemu-aarch64_img.sh](https://github.com/unifreq/openwrt_packit/blob/master/mk_qemu-aarch64_img.sh), разработанного [unifreq](https://github.com/unifreq/openwrt_packit); инструкции по установке и использованию приведены в документе [qemu-aarch64-readme.md](https://github.com/unifreq/openwrt_packit/blob/master/files/qemu-aarch64/qemu-aarch64-readme.md). Прошивка OpenWrt QEMU для функции `Онлайн-загрузка и обновление` предоставлена [breakingbadboy](https://github.com/breakingbadboy/OpenWrt).

Плагин работает в KVM-виртуальной машине точно так же, как и при использовании OpenWrt непосредственно на устройстве.

## Инструкция по сборке системы OpenWrt

Шаг 1. Компиляция файла Rootfs: используя исходный код OpenWrt, в разделе `Target System` выберите `Arm SystemReady (EFI) compliant`, в `Subtarget` — `64-bit (armv8) machines`, в `Target Profile` — `Generic EFI Boot`, и добавьте [обязательные пакеты](https://github.com/ophub/amlogic-s9xxx-openwrt/blob/main/documents/README.md#1011-required-openwrt-options) для компиляции файла `rootfs.tar.gz` OpenWrt.

Шаг 2. Упаковка специализированной прошивки OpenWrt для конкретных устройств: используйте скрипты от [flippy](https://github.com/unifreq/openwrt_packit) или [ophub](https://github.com/ophub/amlogic-s9xxx-openwrt) для создания специализированной прошивки. Подробные инструкции по использованию см. в соответствующих репозиториях.

## Интерфейс плагина

![luci-app-amlogic](https://user-images.githubusercontent.com/68696949/145738345-31dd85cf-5e43-444e-a624-f21a28be2a7c.gif)

## Благодарности

- Ядро и скрипты предоставлены [unifreq](https://github.com/unifreq)
- Функции загрузки и скачивания файлов основаны на [luci-app-filetransfer](https://github.com/coolsnowwolf/luci/tree/master/applications/luci-app-filetransfer)
- Функция настройки ЦП основана на [luci-app-cpufreq](https://github.com/coolsnowwolf/luci/tree/master/applications/luci-app-cpufreq)

## Ссылки

- [OpenWrt](https://github.com/openwrt/openwrt)
- [coolsnowwolf/lede](https://github.com/coolsnowwolf/lede)
- [immortalwrt](https://github.com/immortalwrt/immortalwrt)
- [unifreq/openwrt_packit](https://github.com/unifreq/openwrt_packit)
- [breakingbadboy/OpenWrt](https://github.com/breakingbadboy/OpenWrt)

## Лицензия

The luci-app-amlogic © OPHUB is licensed under [GPL-2.0](https://github.com/ophub/luci-app-amlogic/blob/main/LICENSE)
