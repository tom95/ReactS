rendering
renderingWithChildren: node during: aBlock

	| renderResult isKeyed |
	isKeyed := node hasKey.
	self resetCurrentParentEntryAndChildPointerAfter: [| currentEntry renderInfo numHooks renderResultAndNumHooks |
		isKeyed ifTrue: [currentChildPointer := JsonObject newFrom: {#type -> #key. #index -> nil. #key -> node key}].
		
		currentEntry := self currentEntryOrNil.
		renderInfo := CMFReactRenderInfo from: currentEntry.
		true caseOf: {
			[currentEntry isNil] -> [
				"no old node exists. Append the new node as a new child."
				"Transcript showln: 'throwing away old node (missing)'."
				renderInfo reusingOldNodes: false.
				currentParentEntry := isKeyed 
					ifTrue: [currentParentEntry addKeyedChildNodeToTree: node key: node key]
					ifFalse: [currentParentEntry addChildNodeToTree: node]].
			[currentEntry nodeType ~= node type] -> [
				"an old node exists, but has a different node type. Replace the old node."
				"Transcript showln: 'throwing away old node (type changed from ', currentEntry nodeType, ' to ', node type, ')'."
				renderInfo reusingOldNodes: false.
				currentParentEntry := isKeyed 
					ifTrue: [currentParentEntry replaceKeyedChildTreeNodeWithKey: node key with: node]
					ifFalse: [currentParentEntry replaceChildTreeNodeAt: currentChildPointer index with: node]]}
			otherwise: [
				"an old node exists, and has the same node type. Re-use the old node."
				"Transcript showln: 'keeping old node'."
				renderInfo reusingOldNodes: true.
				currentParentEntry := currentEntry
					node: node;
					yourself].
		
		"in any case,  reset the currentChildPointer, since we changed the parent to the newly inserted node."
		currentChildPointer := JsonObject newFrom: {#type -> #index. #index -> 1. #key -> nil}.
		
		"now render the new node, and pass it the old node"
		renderResultAndNumHooks := aBlock value: renderInfo.
		renderResult := renderResultAndNumHooks first.
		numHooks  := renderResultAndNumHooks second.
		currentParentEntry renderResult: renderResult.
		currentParentEntry numHooks: numHooks].
	
	
	"Now that this node and its children have rendered, and the currentParentNode and currentChildIndex have been reset, increment the currentChildIndex if it was not a keyed node"
	isKeyed ifFalse: [
		currentChildPointer := currentChildPointer copy
			index: currentChildPointer index + 1;
			yourself].
	^ renderResult