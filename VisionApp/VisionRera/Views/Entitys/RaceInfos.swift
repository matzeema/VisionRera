//
//  FastestRound.swift
//  VisionRera
//
//  Created by Mattias Emanuel on 20.02.25.
//

import SwiftUI
import RealityKit

/// Race infos are shown in the center on top of the track. Shows information like
/// new fastest lap or an countdown when starting a race.
@MainActor
class RaceInfosEntityHandler {
    
    var realityViewContent: RealityViewContent?
    
    enum Info {
        case empty
        case fastestLap(Lap)
    }
    private(set) var currentInfo: Info = .empty
    
    private var mainEntity: Entity?
    private let fastestLapEntityHandler = FastestLapEntityHandler()
    
    /// Creates a new container entity for the race infos if non is aleady there and updates the transform of it.
    /// The `realityViewContent` has to set before using this function, otherwise it will do nothing.
    func setRaceInfosTransform(transform: Transform) {
        guard let realityViewContent else { return }
        
        // Create a new main entity if there is no current one.
        if mainEntity == nil {
            mainEntity = Entity()
            realityViewContent.add(mainEntity!)
        }
        
        // The mainEntity should never be nil here, but for simpler
        // and safer code we still use the guard statement.
        guard let mainEntity else { return }
        
        mainEntity.position = transform.translation
        
        // Convert to Rotation3D to easier remove rotation around x and z axis.
        var rotation = Rotation3D(transform.rotation)
        rotation.axis.x = 0
        rotation.axis.z = 0
        mainEntity.transform.rotation = simd_quatf(rotation)
    }
    
    /// Removes all race infos. You have to call `setRaceInfosTransform` before requesting race infos again.
    func removeAllRaceInfos() {
        mainEntity?.removeFromParent()
        mainEntity = nil
    }
    
    /// Requests to show the type of info. Based on the current info and state, the presentation
    /// can happen immediately, be delayed or never shown.
    func requestRaceInfo(_ requestInfo: Info) {
        guard let mainEntity else { return }
        
        // For now we just return if there is already presented some race infos.
        if case .fastestLap(_) = currentInfo {
            return
        }
        
        switch requestInfo {
        case .fastestLap(let lap):
            currentInfo = .fastestLap(lap)
            
            let fastestEntity = fastestLapEntityHandler.createFastestLapEntity(lap: lap)
            let fastestLapWidth = fastestEntity.visualBounds(relativeTo: nil).extents.x
            
            fastestEntity.position = [ -(fastestLapWidth / 2), 0.2, 0 ]
            mainEntity.addChild(fastestEntity)
            
            // After 1.5 seconds remove the entity and reset currentInfo
            Task {
                try await Task.sleep(for: .milliseconds(2500))
                fastestEntity.removeFromParent()
                currentInfo = .empty
                
                print("fastest lap entity removed")
            }
            
        default: break
        }
    }
}

@MainActor
private struct FastestLapEntityHandler {
    
    func createFastestLapEntity(lap: Lap) -> Entity {
        let containerEntity = Entity()
        
        // Create text entity
        let textEntity = createTextEntity(lap: lap)
        containerEntity.addChild(textEntity)
        
        // Create particle entity
        let particleEntity = createParticleEntity()
        let textEntityBounds = textEntity.visualBounds(relativeTo: nil)
        var position = textEntityBounds.center
        position.y -= 0.01
        particleEntity.setPosition(position, relativeTo: textEntity)
        containerEntity.addChild(particleEntity)
        
        // Play audio
        do {
            let resource = try AudioFileResource.load(named: "SoundEffect_NewFastestLap.mp3")
            containerEntity.playAudio(resource)
        } catch {
            assertionFailure("Failed to load audio file for fastest lap sound.")
        }
        
        return containerEntity
    }
    
    private func createTextEntity(lap: Lap) -> Entity {
        let durationInMillis = lap.durationInMillis ?? 0
        
        // First line
        var textString = AttributedString("\(durationInMillis) ms")
        textString.font = .systemFont(ofSize: 6.0, weight: .bold)

        // Text for second line
        let secondLineFont = UIFont.systemFont(ofSize: 3.0, weight: .bold)
        let attributes = AttributeContainer([.font: secondLineFont])
        textString.append(AttributedString("\nNew fastest lap!", attributes: attributes))

        // Multiline center text
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let centerAttributes = AttributeContainer([.paragraphStyle: paragraphStyle])
        textString.mergeAttributes(centerAttributes)

        // Extrusion options
        var extrusionOptions = MeshResource.ShapeExtrusionOptions()
        extrusionOptions.extrusionMethod = .linear(depth: 0.5)
        extrusionOptions.chamferRadius = 0.1

        // Create entity
        do {
            let textMesh = try MeshResource(extruding: textString, extrusionOptions: extrusionOptions)
            let model = ModelEntity(mesh: textMesh, materials: [PhysicallyBasedMaterial()])
            return model
            
        } catch {
            assertionFailure("Unable to create fastest lap text entity: \(error)")
            return Entity()
        }
    }
    
    private func createParticleEntity() -> Entity {
        let emitterComponent = ParticleEmitterComponent.Presets.impact
        return Entity(components: [emitterComponent])
    }
}

#Preview {
    let fastestLapEntityHandler = FastestLapEntityHandler()
    
    RealityView { content in
        let entity = fastestLapEntityHandler.createFastestLapEntity(lap: Lap(id: 1, startMillis: 0, endMillis: 3209))
        
        content.add(entity)
    }
}
