﻿using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using Telegram.Bot;
using Telegram.Bot.Exceptions;
using Telegram.Bot.Extensions.Polling;
using Telegram.Bot.Types;
using Telegram.Bot.Types.Enums;


namespace NeuralNetwork1
{
    class TLGBotik
    {
        public Telegram.Bot.TelegramBotClient botik = null;

        private UpdateTLGMessages formUpdater;
        private DatasetGetter getter;
        private MagicEye processor;

        private BaseNetwork perseptron = null;
        // CancellationToken - инструмент для отмены задач, запущенных в отдельном потоке
        private readonly CancellationTokenSource cts = new CancellationTokenSource();
        public TLGBotik(BaseNetwork net,  UpdateTLGMessages updater)
        { 
            var botKey = System.IO.File.ReadAllText("botkey.txt");
            botik = new Telegram.Bot.TelegramBotClient(botKey);
            formUpdater = updater;
            perseptron = net;
        }

        public void SetDatasetGetter(DatasetGetter datasetGetter)
        {
            getter = datasetGetter;
        }
        public void SetProcessor(MagicEye proc)
        {
            processor = proc;
        }
        public void SetNet(BaseNetwork net)
        {
            perseptron = net;
            formUpdater("Net updated!");
        }

        private async Task HandleUpdateMessageAsync(ITelegramBotClient botClient, Update update, CancellationToken cancellationToken)
        {
            //  Тут очень простое дело - банально отправляем назад сообщения
            var message = update.Message;
            formUpdater("ID:" + message.Chat.Id.ToString() + " Тип сообщения: " + message.Type.ToString());
            

            //  Получение файла (картинки)
            if (message.Type == Telegram.Bot.Types.Enums.MessageType.Photo)
            {
                formUpdater("Picture loadining started");
                var photoId = message.Photo.Last().FileId;
                Telegram.Bot.Types.File fl = botik.GetFileAsync(photoId).Result;
                var imageStream = new MemoryStream();
                await botik.DownloadFileAsync(fl.FilePath, imageStream, cancellationToken: cancellationToken);
                var img = System.Drawing.Image.FromStream(imageStream);
                
                System.Drawing.Bitmap bm = new System.Drawing.Bitmap(img);

                //  Масштабируем aforge
                AForge.Imaging.Filters.ResizeBilinear scaleFilter = new AForge.Imaging.Filters.ResizeBilinear(200,200);
                var uProcessed = scaleFilter.Apply(AForge.Imaging.UnmanagedImage.FromManagedImage(bm));

                //Sample sample = DatasetGetter.ProcessToSample(bm);
                Sample sample = DatasetGetter.ProcessToSample(processor.ToBinary(bm));

                perseptron.Predict(sample);
                StringBuilder sb = new StringBuilder();
                double[] output = perseptron.getOutput();
                string[] vals = getter.dict.Values.ToArray();
                List<(string, double)> list = new List<(string, double)>();
                for (int i = 0; i < output.Length; i++)
                {
                    list.Add((vals[i], output[i]));
                }
                list = list.OrderByDescending(x => x.Item2).ToList();
                await botik.SendTextMessageAsync(message.Chat.Id, string.Join("\n", list));

                //switch(perseptron.Predict(sample))
                //{
                //    case FigureType.Beta: botik.SendTextMessageAsync(message.Chat.Id, "Бета!");break;
                //    case FigureType.Chi: botik.SendTextMessageAsync(message.Chat.Id, "Хи!"); break;
                //    case FigureType.Eta: botik.SendTextMessageAsync(message.Chat.Id, "Эта!"); break;
                //    case FigureType.Iota: botik.SendTextMessageAsync(message.Chat.Id, "Йота!"); break;
                //    case FigureType.Nu: botik.SendTextMessageAsync(message.Chat.Id, "Йота!"); break;
                //    case FigureType.Omicron: botik.SendTextMessageAsync(message.Chat.Id, "Омикрон!"); break;
                //    case FigureType.Psi: botik.SendTextMessageAsync(message.Chat.Id, "Пси!"); break;
                //    case FigureType.Tau: botik.SendTextMessageAsync(message.Chat.Id, "Тау!"); break;
                //    default: botik.SendTextMessageAsync(message.Chat.Id, "Я такого не знаю!"); break;
                //}

                formUpdater("Picture recognized!");
                return;
            }
            else if(message.Type == MessageType.Text)
            {
                botik.SendTextMessageAsync(message.Chat.Id, "Bot reply : " + message.Text);
                formUpdater(message.Text);
            }
            else
            {
                botik.SendTextMessageAsync(message.Chat.Id, "Сделаю вид, что я этого не видел");
            }

            return;
        }
        Task HandleErrorAsync(ITelegramBotClient botClient, Exception exception, CancellationToken cancellationToken)
        {
            var apiRequestException = exception as ApiRequestException;
            if (apiRequestException != null)
                Console.WriteLine($"Telegram API Error:\n[{apiRequestException.ErrorCode}]\n{apiRequestException.Message}");
            else
                Console.WriteLine(exception.ToString());
            return Task.CompletedTask;
        }

        public bool Act()
        {
            try
            {
                botik.StartReceiving(HandleUpdateMessageAsync, HandleErrorAsync, new ReceiverOptions
                {   // Подписываемся только на сообщения
                    AllowedUpdates = new[] { UpdateType.Message }
                },
                cancellationToken: cts.Token);
                // Пробуем получить логин бота - тестируем соединение и токен
                Console.WriteLine($"Connected as {botik.GetMeAsync().Result}");
            }
            catch(Exception e) { 
                return false;
            }
            return true;
        }

        public void Stop()
        {
            cts.Cancel();
        }

    }
}
