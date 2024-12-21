using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using AIMLbot;

namespace NeuralNetwork1
{
    class AIMLBotik
    {
        Bot myBot;
        User myUser;  ///   map[TLGUserID] -> AIML User ID

        public AIMLBotik()
        {
            myBot = new Bot();
            myBot.loadSettings();
            myUser = new User("TLGUser", myBot);
            myBot.isAcceptingUserInput = false;
            myBot.loadAIMLFromFiles();
            myBot.isAcceptingUserInput = true;
        }

        public string Talk(string phrase)
        {
            Request r = new Request(phrase, myUser, myBot);
            Result res = myBot.Chat(r);
            return res.Output;
        }
    }
}
