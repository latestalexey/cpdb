
///////////////////////////////////////////////////////////////////////////////////////////////////
// Прикладной интерфейс

Перем Лог;
Перем ИспользуемаяВерсияПлатформы;

Процедура ЗарегистрироватьКоманду(Знач ИмяКоманды, Знач Парсер) Экспорт
	
	ОписаниеКоманды = Парсер.ОписаниеКоманды(ИмяКоманды, "Загружает информационную базу из файла");

	Парсер.ДобавитьПозиционныйПараметрКоманды(ОписаниеКоманды, "СтрокаПодключения", "Строка подключения к ИБ");
	Парсер.ДобавитьПозиционныйПараметрКоманды(ОписаниеКоманды, "ПутьКФайлу", "Путь к файлу для загрузки в ИБ");

	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, 
		"-db-user",
		"Пользователь ИБ");
	
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, 
		"-db-pwd",
		"Пароль пользователя ИБ");

    Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, 
    	"-v8version",
    	"Маска версии платформы 1С");

	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, 
		"-uccode",
		"Ключ разрешения запуска ИБ");

	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, 
		"-delsource",
		"Удалить файл после загрузки");

    Парсер.ДобавитьКоманду(ОписаниеКоманды);

КонецПроцедуры

Функция ВыполнитьКоманду(Знач ПараметрыКоманды) Экспорт
    
	СтрокаПодключения			= ПараметрыКоманды["СтрокаПодключения"];
	ПутьКФайлу					= ПараметрыКоманды["ПутьКФайлу"];
	Пользователь				= ПараметрыКоманды["-db-user"];
	ПарольПользователя			= ПараметрыКоманды["-db-pwd"];
	ИспользуемаяВерсияПлатформы	= ПараметрыКоманды["-v8version"];
	КлючРазрешения				= ПараметрыКоманды["-uccode"];
	УдалитьИсточник				= ПараметрыКоманды["-delsource"];

	ВозможныйРезультат = МенеджерКомандПриложения.РезультатыКоманд();

	Если ПустаяСтрока(СтрокаПодключения) Тогда
		Лог.Ошибка("Не указана строка подключения к ИБ");
		Возврат ВозможныйРезультат.НеверныеПараметры;
	КонецЕсли;

	Если ПустаяСтрока(ПутьКФайлу) Тогда
		Лог.Ошибка("Не указан путь к файлу для выгрузки ИБ");
		Возврат ВозможныйРезультат.НеверныеПараметры;
	КонецЕсли;

	Попытка
		ВыполнитьЗагрузкуИБ(СтрокаПодключения
						  , ПутьКФайлу
						  , Пользователь
						  , ПарольПользователя
						  , КлючРазрешения);

		Если УдалитьИсточник Тогда
			УдалитьФайлы(ПутьКФайлу);
			Лог.Информация(СтрШаблон("Исходный файл %1 удален", ПутьКФайлу));
		КонецЕсли;
		
		Возврат ВозможныйРезультат.Успех;
	Исключение
		Лог.Ошибка(ОписаниеОшибки());
		Возврат ВозможныйРезультат.ОшибкаВремениВыполнения;
	КонецПопытки;

КонецФункции

Процедура ВыполнитьЗагрузкуИБ(Знач СтрокаПодключения
							, Знач ПутьФайлу
							, Знач ИмяПользователя
							, Знач ПарольПользователя
							, Знач КлючРазрешения)

	Конфигуратор = ЗапускПриложений.НастроитьКонфигуратор(СтрокаПодключения
														, ИмяПользователя
														, ПарольПользователя
														, ИспользуемаяВерсияПлатформы);
	
	Если Не ПустаяСтрока(КлючРазрешения) Тогда
		Конфигуратор.УстановитьКлючРазрешенияЗапуска(КлючРазрешения);
	КонецЕсли;

	Конфигуратор.ЗагрузитьИнформационнуюБазу(ПутьФайлу);

КонецПроцедуры

Лог = Логирование.ПолучитьЛог("ktb.app.copydb");