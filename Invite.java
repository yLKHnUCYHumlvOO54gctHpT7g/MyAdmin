const { Client, GatewayIntentBits } = require('discord.js');
const express = require('express');
const app = express();
const botToken = 'YOUR_BOT_TOKEN';  // Your bot token here
const client = new Client({ intents: [GatewayIntentBits.Guilds] });

// Set up your server route to create a Discord invite
app.get('/createinvite', (req, res) => {
    client.once('ready', async () => {
        // Use the bot to create an invite in your desired channel
        const channel = await client.channels.fetch('YOUR_CHANNEL_ID');
        const invite = await channel.createInvite({
            maxAge: 3600, // 1 hour expiration time
            maxUses: 10   // Limit of 10 uses
        });

        res.json({ inviteUrl: invite.url });
    });

    client.login(botToken);
});

// Start the server
app.listen(3000, () => {
    console.log('Server running on port 3000');
});
