class TestMailer < ApplicationMailer
  def send_mail
      mail_info = {
        to: 'hoge.from@test.com',
        from: 'fuga.to@test.com',
        from_display_name: 'ほげ商事',
        subject: 'ほげ商事の田中太郎です',
        body: '本メールはほげ商事の田中太郎からのテストメールです。'
      }

    from = Mail::Address.new mail_info[:from]
    from.display_name = mail_info[:from_display_name]
    mail(subject: mail_info[:subject], from: from.format, to: mail_info[:to]) do |format|
      format.text { render plain: mail_info[:body] }
    end

  end
end