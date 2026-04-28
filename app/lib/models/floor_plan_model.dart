class GraphNode {
  final String id;
  final double x;
  final double y;
  final List<String> connectedNodeIds;
  final bool isExit;
  final bool isStairwell;
  final bool isElevator; // Used to lock elevators during fire

  GraphNode({
    required this.id,
    required this.x,
    required this.y,
    required this.connectedNodeIds,
    this.isExit = false,
    this.isStairwell = false,
    this.isElevator = false,
  });

  factory GraphNode.fromMap(Map<String, dynamic> data) {
    return GraphNode(
      id: data['id'] ?? '',
      x: data['x']?.toDouble() ?? 0.0,
      y: data['y']?.toDouble() ?? 0.0,
      connectedNodeIds: List<String>.from(data['connectedNodeIds'] ?? []),
      isExit: data['isExit'] ?? false,
      isStairwell: data['isStairwell'] ?? false,
      isElevator: data['isElevator'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'x': x,
      'y': y,
      'connectedNodeIds': connectedNodeIds,
      'isExit': isExit,
      'isStairwell': isStairwell,
      'isElevator': isElevator,
    };
  }
}

class FloorPlanModel {
  final String id;
  final String floorName;
  final String imageUrl; // Firebase Storage URL
  final List<String> exitCoordinates; // Keep for backwards compatibility
  final List<String> stairwellCoordinates;
  final List<String> assemblyPoints;
  
  // Dynamic Evacuation Engine Metadata
  final List<GraphNode> pathfindingNodes; // The pre-computed walkable graph
  final List<String> blockedPaths; // Node IDs or Edge IDs currently blocked
  final List<String> unsafeZones; // Node IDs considered dangerous (smoke/fire)
  final List<String> simulatedLedPaths; // Node IDs currently flashing for demo

  FloorPlanModel({
    required this.id,
    required this.floorName,
    required this.imageUrl,
    this.exitCoordinates = const [],
    this.stairwellCoordinates = const [],
    this.assemblyPoints = const [],
    this.pathfindingNodes = const [],
    this.blockedPaths = const [],
    this.unsafeZones = const [],
    this.simulatedLedPaths = const [],
  });

  factory FloorPlanModel.fromMap(Map<String, dynamic> data, String documentId) {
    return FloorPlanModel(
      id: documentId,
      floorName: data['floorName'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      exitCoordinates: List<String>.from(data['exitCoordinates'] ?? []),
      stairwellCoordinates: List<String>.from(data['stairwellCoordinates'] ?? []),
      assemblyPoints: List<String>.from(data['assemblyPoints'] ?? []),
      pathfindingNodes: (data['pathfindingNodes'] as List<dynamic>? ?? [])
          .map((n) => GraphNode.fromMap(n))
          .toList(),
      blockedPaths: List<String>.from(data['blockedPaths'] ?? []),
      unsafeZones: List<String>.from(data['unsafeZones'] ?? []),
      simulatedLedPaths: List<String>.from(data['simulatedLedPaths'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'floorName': floorName,
      'imageUrl': imageUrl,
      'exitCoordinates': exitCoordinates,
      'stairwellCoordinates': stairwellCoordinates,
      'assemblyPoints': assemblyPoints,
      'pathfindingNodes': pathfindingNodes.map((n) => n.toMap()).toList(),
      'blockedPaths': blockedPaths,
      'unsafeZones': unsafeZones,
      'simulatedLedPaths': simulatedLedPaths,
    };
  }
}

