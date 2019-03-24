import UIKit
import SceneKit
import ARKit

class ViewController_L: UIViewController, ARSCNViewDelegate, ARSessionDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        sceneView.scene = SCNScene()
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        // ライト追加
        let omniLightNode = SCNNode()
        omniLightNode.name = "omniLight"
        omniLightNode.light = SCNLight()
        omniLightNode.light!.type = .omni
        omniLightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        omniLightNode.light!.color = UIColor.white
        self.sceneView.scene.rootNode.addChildNode(omniLightNode)
        
        // タップの登録
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action:
            #selector(tapped))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        // 平面検出
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
    }
    
    @objc func tapped(sender: UITapGestureRecognizer) {
        // タップされた位置を取得する
        let tapLocation = sender.location(in: sceneView)
        // タップされた位置のARアンカーを探す
        let hitTest = sceneView.hitTest(tapLocation,
                                        types: .existingPlaneUsingExtent)
        if !hitTest.isEmpty {
            // タップした箇所が取得できていればitemを追加
            let anchor = ARAnchor(transform: hitTest.first!.worldTransform)
            sceneView.session.add(anchor: anchor)
        }
    }
    
    // 平面を検出したときに呼ばれる
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor:
        ARAnchor) {
        guard !(anchor is ARPlaneAnchor) else { return }
        // scnファイルからシーンを読み込み
        let scene = SCNScene(named: "art.scnassets/L_Pizza.scn")
        // シーンからノードを検索
        let pizzaNode = (scene?.rootNode.childNode(withName: "pizza",
                                                   recursively: false))!
        // 検出面の子要素にする
        node.addChildNode(pizzaNode)
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for
        anchor: ARAnchor) {
        // ライトのノードを探す
        let omniNode = (self.sceneView.scene.rootNode.childNode(withName:
            "omniLight", recursively: false))!
        // ライトの推定値で更新
        omniNode.light?.intensity = (self.sceneView.session.currentFrame!.lightEstimate?.ambientIntensity)!
        omniNode.light?.temperature = (self.sceneView.session.currentFrame!.lightEstimate?.ambientColorTemperature)!
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        sceneView.session.pause()
    }
    
    
}







