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
struct RaceInfosEntityHandler {
    
    /// Conatiner to hold the info entitys.
    let mainEntity = Entity()
    
    
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
