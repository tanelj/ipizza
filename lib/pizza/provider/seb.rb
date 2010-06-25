module Pizza::Provider
  class SEB
    
    cattr_accessor :service_url, :return_url, :cancel_url, :key, :key_secret, :cert, :snd_id, :encoding, :rec_acc, :rec_name
    
    def payment_request(payment, service = 1002)
      req = Pizza::PaymentRequest.new
      req.service_url = self.service_url
      req.sign_params = {
        'VK_SERVICE' => service.to_s,
        'VK_VERSION' => '008',
        'VK_SND_ID' => self.snd_id,
        'VK_STAMP' => payment.stamp,
        'VK_AMOUNT' => sprintf('%.2f', payment.amount),
        'VK_CURR' => payment.currency,
        'VK_REF' => Pizza::Util.sign_731(payment.refnum),
        'VK_MSG' => payment.message
      }
      
      if service == 1001
        req.sign_params['VK_ACC'] = self.rec_acc
        req.sign_params['VK_NAME'] = self.rec_name
      end
      
      req.extra_params = {
        'VK_CHARSET' => self.encoding,
        'VK_RETURN' => self.return_url,
        'VK_CANCEL' => self.cancel_url
      }
      
      if service == 1001
        param_order = ['VK_SERVICE', 'VK_VERSION', 'VK_SND_ID', 'VK_STAMP', 'VK_AMOUNT', 'VK_CURR', 'VK_ACC', 'VK_NAME', 'VK_REF', 'VK_MSG']
      else
        param_order = ['VK_SERVICE', 'VK_VERSION', 'VK_SND_ID', 'VK_STAMP', 'VK_AMOUNT', 'VK_CURR', 'VK_REF', 'VK_MSG']
      end

      req.sign(self.key, self.key_secret, param_order)
      req
    end
    
    def payment_response(params)
      response = Pizza::PaymentResponse.new(params, Pizza::Util::SEB)
      response.verify(cert)
      
      return response
    end
  end
end
