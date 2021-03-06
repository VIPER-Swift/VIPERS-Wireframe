
Pod::Spec.new do |s|
  s.name             = "VIPERS-Wireframe"
  s.version          = "0.1.0"
  s.summary          = "Wireframe / router implementation."


  s.description      = <<-DESC
The wireframe layer in an VIPER-Application is used to create and to present view controllers and controller transitions. A VIPERS application uses an object conforming to the WireframeProtocol to route between the controllers of your app.

It is the powerful thing that wires the view controllers in your app together. It takes an NSURL and some parameters, talks to the components that create your view controllers (the ControllerProvider) which create the view controller connected to this URL, and gives it to those components which are responsible for presenting your controller (the ControllerRoutingPresenter).

The wireframe is responsible for navigating to the next view controller and communicates and connects all objects of the wireframe layer. It is used by the presenter layer to navigate to the next view controller. We recommend you to avoid using it in a view controller which is located in the view layer. It is better to call it from a delegate.
                       DESC

  s.homepage         = "https://github.com/VIPER-Swift/VIPERS-Wireframe"
  s.license          = 'MIT'
  s.author           = { "Jan Bartel" => "jan.bartel@atino.net" }
  s.source           = { :git => "https://github.com/VIPER-Swift/VIPERS-Wireframe.git", :tag => s.version.to_s }


  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'VIPERS-Wireframe' => ['Pod/Assets/*.png']
  }

  s.dependency 'VIPERS-Wireframe-Protocol'
  s.dependency 'JLRoutes'

end
