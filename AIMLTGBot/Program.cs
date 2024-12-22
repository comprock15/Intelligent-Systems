using System;

namespace AIMLTGBot
{
    class Program
    {
        static void Main(string[] args)
        {
            var token = System.IO.File.ReadAllText("TGToken.txt");
            if (token == "FILL_ME")
            {
                Console.WriteLine("Для работы с телеграмом необходимо завести бота и получить токен (https://core.telegram.org/bots#6-botfather). Положите его в файл TGToken.txt и перезапустите программу." +
                    Environment.NewLine +
                    "Помните, что токен является секретом и должен быть исключён из отслеживания гитом!");
                Console.ReadLine();
                return;
            }
            using (var tg = new TelegramService(token, new AIMLService()))
            {
                Console.WriteLine($"Подключились к телеграмму как бот { tg.Username }. Ожидаем сообщений. Для завершения работы нажимте Enter");
                Console.ReadLine();
            }
        }
    }
}
