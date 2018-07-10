class MessengerNotificationWorker
  include Sidekiq::Worker

  def perform(mtd_name, *args)
    MessengerNotificationService.send(mtd_name, *args)
  end
end
