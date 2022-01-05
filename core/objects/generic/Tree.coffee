import TreeNode from './TreeNode.coffee'

export class Tree

	constructor: (value) ->
		@rootNode =
			if value instanceof TreeNode
				value
			else
				new TreeNode(value)

	getRoot: () ->
		return @rootNode

	add: (value, parentNode) ->
		childNode =
			if value instanceof TreeNode
				value
			else
				new TreeNode(value)
		parentNode.addChild(childNode)
		return childNode

	pop: () ->
		return [rootNode.getValue(), @rootNode.getChildren().map((childNode) -> new Tree(childNode))]