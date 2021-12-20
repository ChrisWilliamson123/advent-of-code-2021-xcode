import simd

struct RotationMatrixStore {
    static let allRotationMatrices: [float4x4] = [
        float4x4(rows:[simd_float4(1,    0,    0, 0),
                       simd_float4(0,    1,    0, 0),
                       simd_float4(0,    0,    1, 0),
                       simd_float4(0,    0,    0, 1)]),

        float4x4(rows:[simd_float4(1,    0,    0, 0),
                       simd_float4(0,    0,    -1, 0),
                       simd_float4(0,    1,    0, 0),
                       simd_float4(0,    0,    0, 1)]),

        float4x4(rows:[simd_float4(1,    0,    0, 0),
                       simd_float4(0,    -1,    0, 0),
                       simd_float4(0,    0,    -1, 0),
                       simd_float4(0,    0,    0, 1)]),

        float4x4(rows:[simd_float4(1,    0,    0, 0),
                       simd_float4(0,    0,    1, 0),
                       simd_float4(0,    -1,    0, 0),
                       simd_float4(0,    0,    0, 1)]),

        float4x4(rows:[simd_float4(0,    -1,    0, 0),
                       simd_float4(1,    0,    0, 0),
                       simd_float4(0,    0,    1, 0),
                       simd_float4(0,    0,    0, 1)]),

        float4x4(rows:[simd_float4(0,    0,    1, 0),
                       simd_float4(1,    0,    0, 0),
                       simd_float4(0,    1,    0, 0),
                       simd_float4(0,    0,    0, 1)]),

        float4x4(rows:[simd_float4(0,    1,    0, 0),
                       simd_float4(1,    0,    0, 0),
                       simd_float4(0,    0,    -1, 0),
                       simd_float4(0,    0,    0, 1)]),

        float4x4(rows:[simd_float4(0,    0,    -1, 0),
                       simd_float4(1,    0,    0, 0),
                       simd_float4(0,    -1,    0, 0),
                       simd_float4(0,    0,    0, 1)]),

        float4x4(rows:[simd_float4(-1,    0, 0,    0),
                       simd_float4(0,    -1,    0, 0),
                       simd_float4(0,    0,    1, 0),
                       simd_float4(0,    0,    0, 1)]),

        float4x4(rows:[simd_float4(-1,    0, 0,    0),
                       simd_float4(0,    0,    -1, 0),
                       simd_float4(0,    -1,    0, 0),
                       simd_float4(0,    0,    0, 1)]),

        float4x4(rows:[simd_float4(-1,    0, 0,    0),
                       simd_float4(0,    1,    0, 0),
                       simd_float4(0,    0,    -1, 0),
                       simd_float4(0,    0,    0, 1)]),

        float4x4(rows:[simd_float4(-1,    0, 0,    0),
                       simd_float4(0,    0,    1, 0),
                       simd_float4(0,    1,    0, 0),
                       simd_float4(0,    0,    0, 1)]),

        float4x4(rows:[simd_float4(0,    1,    0, 0),
                       simd_float4(-1,    0, 0,    0),
                       simd_float4(0,    0,    1, 0),
                       simd_float4(0,    0,    0, 1)]),

        float4x4(rows:[simd_float4(0,    0,    1, 0),
                       simd_float4(-1,    0, 0,    0),
                       simd_float4(0,    -1,    0, 0),
                       simd_float4(0,    0,    0, 1)]),

        float4x4(rows:[simd_float4(0,    -1,    0, 0),
                       simd_float4(-1,    0, 0,    0),
                       simd_float4(0,    0,    -1, 0),
                       simd_float4(0,    0,    0, 1)]),

        float4x4(rows:[simd_float4(0,    0,    -1, 0),
                       simd_float4(-1,    0, 0,    0),
                       simd_float4(0,    1,    0, 0),
                       simd_float4(0,    0,    0, 1)]),

        float4x4(rows:[simd_float4(0,    0,    -1, 0),
                       simd_float4(0,    1,    0, 0),
                       simd_float4(1,    0,    0, 0),
                       simd_float4(0,    0,    0, 1)]),

        float4x4(rows:[simd_float4(0,    1,    0, 0),
                       simd_float4(0,    0,    1, 0),
                       simd_float4(1,    0,    0, 0),
                       simd_float4(0,    0,    0, 1)]),

        float4x4(rows:[simd_float4(0,    0,    1, 0),
                       simd_float4(0,    -1,    0, 0),
                       simd_float4(1,    0,    0, 0),
                       simd_float4(0,    0,    0, 1)]),

        float4x4(rows:[simd_float4(0,    -1,    0, 0),
                       simd_float4(0,    0,    -1, 0),
                       simd_float4(1,    0,    0, 0),
                       simd_float4(0,    0,    0, 1)]),

        float4x4(rows:[simd_float4(0,    0,    -1, 0),
                       simd_float4(0,    -1,    0, 0),
                       simd_float4(-1,    0, 0,    0),
                       simd_float4(0,    0,    0, 1)]),

        float4x4(rows:[simd_float4(0,    -1,    0, 0),
                       simd_float4(0,    0,    1, 0),
                       simd_float4(-1,    0, 0,    0),
                       simd_float4(0,    0,    0, 1)]),

        float4x4(rows:[simd_float4(0,    0,    1, 0),
                       simd_float4(0,    1,    0, 0),
                       simd_float4(-1,    0, 0,    0),
                       simd_float4(0,    0,    0, 1)]),

        float4x4(rows:[simd_float4(0,    1,    0, 0),
                       simd_float4(0,    0,    -1, 0),
                       simd_float4(-1,    0, 0,    0),
                       simd_float4(0,    0,    0, 1)])
    ]
}
