# A Telegram bot to check available dates at GNIB/Dublin/Ireland

## Register your bot on telegram and get your token

[How to create your bot on telegram](https://core.telegram.org/bots)

## Instalation

`gem install telegram_bot`

`gem install rufus-scheduler`

## Configuration

- Set your telegram token
- Set the variable `type` to 'New' if you do not have a GNIB Card or 'Renewal'
if you have one.
- Set the variable `time_to_send_notifications` the interval in seconds to send
the notifications

## Run

`ruby gnib_bot.rb`
