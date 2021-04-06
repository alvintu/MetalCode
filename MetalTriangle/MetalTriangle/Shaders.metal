//
//  Shaders.metal
//  MetalTriangle
//
//  Created by Alvin Tu on 4/6/21.
//

#include <metal_stdlib>
using namespace metal;


vertex float4 basic_vertex( // all vertex shaders must begin with the keyword vertex
const device packed_float3* vertex_array [[buffer(0)]],
      unsigned int vid [[vertex_id]]) {
  return float4(vertex_array[vid], 1.0);
}
                           


//a packed_float3 is a packed vektor of 3 floats, (ie the position of the vertex)
//[[...]] syntax is used to declare attributes, which you can use to specify additional information such as resource locations, shader, inputs and built-in variables, here, you mark this parameter with [[buffer(0)]] to indicate that the first buffer of data that you send to your vertex shader from the metal cod with populate this parameter
//the vertex shader also takes special parameter with vertex_id attribute, which means that the metal will fill in with the index of this particular vertex inside the vertex array
//we look  the positoin inside the vertex array based on the vertex id and return that
//also convert to a float4 where the final value is 1.0 (which is required for 3d math)



fragment half4 basic_fragment() {
  //all fragment shaders must begin with keyword fragment
  
  return half4(1.0); //we return 1,1,1,1 which is white
}
