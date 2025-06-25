every 10.minutes do
    runner "UpdateCoinPricesJob.perform_now"
end
