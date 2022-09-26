function vecAngle = getElbowJointAngle(trial, shoulderName, elbowJointName, wristMarkerName)
	% get elbow vector angle
	% vecAngle = getElbowJointAngle(trial, 'shoulder_right', 'elbow_right', 'wrist_right')
	shoulder_xyz = getTrialXYZ(trial, shoulderName);
	elbow_xyz = getTrialXYZ(trial, elbowJointName);
	wrist_xyz = getTrialXYZ(trial, wristMarkerName);
	% Since elbow join is common, normalize shoulder and wrist wrt elbow
	shoulder_xyz = shoulder_xyz-elbow_xyz;
	wrist_xyz = wrist_xyz-elbow_xyz;
	%				  -1    shoulder_xyz.wrist_xyz
	% vecangle = cosine ( ----------------------------)
	% 					  ||shoulder_xyz||*||wrist_xyz
	shoulder_xyzDotwrist_xyz = dot(shoulder_xyz, wrist_xyz, 2);
	shoulder_xyzNorm = vecnorm(shoulder_xyz,2,2);
	wrist_xyzNorm = vecnorm(wrist_xyz,2,2);
	cosVecAngle = shoulder_xyzDotwrist_xyz./(shoulder_xyzNorm.*wrist_xyzNorm);
	vecAngle = acosd(cosvecangle);