//
//  Quaternion.glsl
//  Aletteration3
//
//  Created by David Nesbitt on 2013-09-20.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

vec3 QuaternionRotateVector(vec4 quat, vec3 vec) {
	return vec + 2.0 * cross(cross(vec, quat.xyz) + quat.w * vec, quat.xyz);
}

vec4 QuaternionMultiply(vec4 quat0, vec4 quat1) {
	return(
		vec4( quat0.w * quat1.x, quat0.w * quat1.y, quat0.w * quat1.z, quat0.w * quat1.w)+
		vec4( quat0.x * quat1.w, quat0.x * quat1.w, quat0.z * quat1.w,-quat0.x * quat1.x)+
		vec4( quat0.y * quat1.z, quat0.z * quat1.x, quat0.x * quat1.y,-quat0.y * quat1.y)+
		vec4(-quat0.z * quat1.y,-quat0.x * quat1.z,-quat0.y * quat1.x,-quat0.z * quat1.z)
	);
}

vec4 QuaternionNormalize(vec4 quat) {
	float scale = 1.0 / length(quat);
	return quat*scale;
}
