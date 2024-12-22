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
        ///   map[TLGUserID] -> AIML User ID
        Dictionary<long, User> users;

        public AIMLBotik()
        {
            myBot = new Bot();
            myBot.loadSettings();
            users = new Dictionary<long, User>();
            myBot.isAcceptingUserInput = false;
            myBot.loadAIMLFromFiles();
            myBot.isAcceptingUserInput = true;
        }

        public string Talk(string phrase, long userID=-1, string username="developer")
        {
            User user = null;
            string result = "";
            if (users.ContainsKey(userID))
            {
                user = users[userID];
            }
            else
            {
                user = AddUser(userID);
                result += myBot.Chat(new Request($"МЕНЯ ЗОВУТ {username}", user, myBot)) + Environment.NewLine;
            }
            Request r = new Request(phrase, user, myBot);
            result += myBot.Chat(r);
            return result;
        }

        public User AddUser(long id)
        {
            users[id] = new User(id.ToString(), myBot);
            return users[id];
        }
    }
}
