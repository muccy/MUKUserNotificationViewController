Pod::Spec.new do |s|
  s.name             = "MUKUserNotificationViewController"
  s.version          = "1.0.0"
  s.summary          = "A view controller which displays user notification replacing status bar."
  s.description      = <<-DESC
                       MUKUserNotificationViewController is a container view controller which displays user notifications where status bar lives.
                       Functionality is highly inspired by Tweetbot.
                       You will have features like:
                       * sticky notifications;
                       * temporary notifications with a custom duration;
                       * queue of notifications with rate limiting;
                       * customizable colors and text;
                       * tap and pan up gestures support.
                       DESC
  s.homepage         = "https://github.com/muccy/MUKUserNotificationViewController"
  s.screenshots     = "http://i.imgur.com/K2uiyTy.png", "http://i.imgur.com/gCnSEvL.png", "http://i.imgur.com/t9bLMB9.png"
  s.license          = 'MIT'
  s.author           = { "Muccy" => "muccymac@gmail.com" }
  s.source           = { :git => "https://github.com/muccy/MUKUserNotificationViewController.git", :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.requires_arc = true
  s.compiler_flags  = '-Wdocumentation'

  s.source_files = 'Pod/Classes'
end
