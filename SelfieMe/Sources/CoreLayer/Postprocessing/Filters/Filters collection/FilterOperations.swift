import Foundation
import GPUImage
import QuartzCore

#if os(iOS)
import OpenGLES
#else
import OpenGL
#endif
    
let filterOperations: Array<FilterOperationInterface> = [
    FilterOperation <GPUImageSaturationFilter>(
        listName:"Saturation",
        titleName:"",
        sliderConfiguration:.enabled(minimumValue:0.0, maximumValue:2.0, initialValue:1.4),
        sliderUpdateCallback: {(filter, sliderValue) in
            filter.saturation = sliderValue
        },
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImageContrastFilter>(
        listName:"Contrast",
        titleName:"",
        sliderConfiguration:.enabled(minimumValue:0.0, maximumValue:4.0, initialValue:1.4),
        sliderUpdateCallback: {(filter, sliderValue) in
            filter.contrast = sliderValue
        },
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImageUnsharpMaskFilter>(
        listName:"Unsharp mask",
        titleName:"",
        sliderConfiguration:.enabled(minimumValue:0.0, maximumValue:5.0, initialValue:2.5),
        sliderUpdateCallback: {(filter, sliderValue) in
            filter.intensity = sliderValue
        },
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImageHazeFilter>(
        listName:"Haze / UV",
        titleName:"",
        sliderConfiguration:.enabled(minimumValue:-0.2, maximumValue:0.2, initialValue:0.2),
        sliderUpdateCallback: {(filter, sliderValue) in
            filter.distance = sliderValue
        },
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImageSepiaFilter>(
        listName:"Sepia tone",
        titleName:"",
        sliderConfiguration:.enabled(minimumValue:0.0, maximumValue:1.0, initialValue:1.0),
        sliderUpdateCallback: {(filter, sliderValue) in
            filter.intensity = sliderValue
        },
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImageAmatorkaFilter>(
        listName:"Amatorka (Lookup)",
        titleName:"",
        sliderConfiguration:.disabled,
        sliderUpdateCallback: nil,
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImageMissEtikateFilter>(
        listName:"Miss Etikate (Lookup)",
        titleName:"",
        sliderConfiguration:.disabled,
        sliderUpdateCallback: nil,
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImageSoftEleganceFilter>(
        listName:"Soft elegance (Lookup)",
        titleName:"",
        sliderConfiguration:.disabled,
        sliderUpdateCallback: nil,
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImageGrayscaleFilter>(
        listName:"Grayscale",
        titleName:"",
        sliderConfiguration:.disabled,
        sliderUpdateCallback: nil,
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImageSketchFilter>(
        listName:"Sketch",
        titleName:"",
        sliderConfiguration:.enabled(minimumValue:0.0, maximumValue:1.0, initialValue:0.5),
        sliderUpdateCallback: {(filter, sliderValue) in
            filter.edgeStrength = sliderValue
        },
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImageToonFilter>(
        listName:"Toon",
        titleName:"",
        sliderConfiguration:.disabled,
        sliderUpdateCallback: nil,
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImageSmoothToonFilter>(
        listName:"Smooth toon",
        titleName:"",
        sliderConfiguration:.enabled(minimumValue:1.0, maximumValue:6.0, initialValue:1.0),
        sliderUpdateCallback: {(filter, sliderValue) in
            filter.blurRadiusInPixels = sliderValue
        },
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImagePosterizeFilter>(
        listName:"Posterize",
        titleName:"",
        sliderConfiguration:.enabled(minimumValue:1.0, maximumValue:20.0, initialValue:10.0),
        sliderUpdateCallback: {(filter, sliderValue) in
            filter.colorLevels = UInt(round(sliderValue))
        },
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImageKuwaharaFilter>(
        listName:"Kuwahara",
        titleName:"",
        sliderConfiguration:.enabled(minimumValue:3.0, maximumValue:8.0, initialValue:5.0),
        sliderUpdateCallback: {(filter, sliderValue) in
            filter.radius = UInt(round(sliderValue))
        },
        filterOperationType:.singleInput
    )
]
