module Retryable
  RETRIES = 5

  def retry_it?(counter_name = caller[0].to_s, delay = 5)
    @retries||={}
    @retries[counter_name]||=0
    @retries[counter_name]+=1

    if @retries[counter_name] <= RETRIES
      sleep(delay) if delay.present?
      true
    else
      false
    end
  end
end