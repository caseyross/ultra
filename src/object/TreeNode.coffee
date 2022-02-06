export class TreeNode

	constructor: (value) ->
		@value = value
		@children = []

	getValue: () ->
		return @value

	getChildren: () ->
		return @children

	addChild: (value) ->
		@children.push(
			if value instanceof TreeNode
				value
			else
				new TreeNode(value)
		)