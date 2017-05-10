require 'telegram_bot'
require 'net/http'
require 'rufus-scheduler'

scheduler = Rufus::Scheduler.new

bot = TelegramBot.new(token: 'YOUR_TELEGRAM_TOKEN_HERE')
type = "Renewal" # or "New" if you do not have a gnib yet
url = "https://burghquayregistrationoffice.inis.gov.ie/Website/AMSREG/AMSRegWeb.nsf/(getAppsNear)?openpage&cat=Work&sbcat=All&typ=" + type + "&_=1493766382089"
uri = URI.parse(url)
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true
OpenSSL::SSL::SSLContext::DEFAULT_PARAMS[:ciphers] = "DES-CBC3-SHA"
http.verify_mode = OpenSSL::SSL::VERIFY_NONE

time_to_send_notifications = "1800" # in seconds
@job_id_2 = nil
job_id =
scheduler.every '5s' do
  message = bot.get_updates(fail_silently: true).last
  unless message.nil?
    message.reply do |reply|
      case message.text
      when /start/i
        job = @job_id_2.nil? ? nil : scheduler.job(@job_id_2)
        if !job.nil?
          scheduler.unschedule(job)
          job.kill
        end
        request = Net::HTTP::Get.new(uri.request_uri)
        response = http.request(request)
        hash = JSON.parse(response.body)
        reply.text = "Available dates:\n\n"
        for i in 0...hash["slots"].length
          reply.text += "#{hash["slots"][i]["time"]}\n"
        end
        reply.send_with(bot)
        @job_id_2 = scheduler.every time_to_send_notifications do
          request = Net::HTTP::Get.new(uri.request_uri)
          response = http.request(request)
          hash = JSON.parse(response.body)
          reply.text = "Available dates:\n\n"
          for i in 0...hash["slots"].length
            reply.text += "#{hash["slots"][i]["time"]}\n"
          end
          reply.send_with(bot)
        end
      when /stop/i
        job = @job_id_2.nil? ? nil : scheduler.job(@job_id_2)
        if !job.nil?
          scheduler.unschedule(job)
          job.kill
          reply.text = "Ok, you don't need my services anymore"
          reply.send_with bot
        else
          reply.text = "I'm already sleeping"
          reply.send_with bot
        end
      end
    end
  end
end
scheduler.join
