module CanhelpPlugin
  def self.set_token(token)
    File.new('.token', 'w')
    File.open('.token', 'w') do |f|
      f.write token
    end
  end
end
