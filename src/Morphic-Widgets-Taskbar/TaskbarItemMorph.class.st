"
Description
--------------------

A TaskbarItemMorph is a Morph representing a unique item of the taskbar. 

It can be customized via the current theme for its border and fill style.

Examples
--------------------

	(TaskbarItemMorph on: aWindow getState: #isActive action: #taskbarButtonClicked)
		initializeFor: aTaskbar;
		yourself
"
Class {
	#name : 'TaskbarItemMorph',
	#superclass : 'PluggableButtonMorph',
	#category : 'Morphic-Widgets-Taskbar',
	#package : 'Morphic-Widgets-Taskbar'
}

{ #category : 'drag and drop' }
TaskbarItemMorph >> acceptDroppingMorph: aTransferMorph event: event [
	"The user dropped a task. Move it to the indicator position."

	| taskbar droppedTask targetIdx |
	taskbar := self owner.
	taskbar ifNil: [ ^ self ].
	(taskbar isKindOf: TaskbarMorph) ifFalse: [ ^ self ].
	droppedTask := aTransferMorph passenger.
	droppedTask ifNil: [ ^ self ].
	targetIdx := taskbar dropTargetIndex.
	targetIdx ifNil: [ ^ self ].
	taskbar moveTask: droppedTask toIndex: targetIdx.
	event hand releaseMouseFocus: self
]

{ #category : 'customization' }
TaskbarItemMorph >> addEmphaseTo: lab [
	"1 -> bold"

	self model isActive ifFalse: [ ^ self ].

	lab emphasis: 1
]

{ #category : 'accessing' }
TaskbarItemMorph >> buildLabelMorph [

	^ self theme buttonLabelForText: self model taskbarLabel
]

{ #category : 'drag and drop' }
TaskbarItemMorph >> click: event [
	"The user clicked (short press) on this button. Activate or minimize the window."

	self performAction: event
]

{ #category : 'style - border' }
TaskbarItemMorph >> disabledBorderStyle [
	"Return the disabled borderStyle of the receiver."

	^ self theme taskbarItemDisabledBorderStyleFor: self
]

{ #category : 'style - filling' }
TaskbarItemMorph >> disabledFillStyle [
	"Return the disabled fillStyle of the receiver."

	^ self theme taskbarItemDisabledFillStyleFor: self
]

{ #category : 'initialization' }
TaskbarItemMorph >> initialize [
	super initialize.
	self borderStyle: (self theme taskbarItemNormalBorderStyleFor: self)
]

{ #category : 'initialization' }
TaskbarItemMorph >> initializeAnnouncements [
	self
		on: #mouseEnter send: #taskbarButtonEntered:event:in: to: self model withValue: self;
		on: #mouseLeave send: #taskbarButtonLeft:event:in: to: self model withValue: self
]

{ #category : 'initialization' }
TaskbarItemMorph >> initializeFor: aTaskbar [
	| lm lab |
	lab := self buildLabelMorph.
	self addEmphaseTo: lab.
	lm := self theme
		newRowIn: aTaskbar
		for:
			{ (self model taskbarIcon ifNil: [ ^ nil ]) asMorph.
			lab}.

	lm cellInset: 2.

	self
		label: lm font: self theme buttonFont;
		extent: self minExtent;
		hResizing: #rigid;
		vResizing: #rigid;
		useSquareCorners;
		getMenuSelector: #taskbarButtonMenu:.
		
	"The following code works like this:
	- A Task takes at least 100px.
	- A Task takes maximum 175px.
	- If possible, we try to have 15 tasks on one level of the taskbar."
	self width: (((aTaskbar innerBounds width // 15) min: 175) max: 100).
	
	self initializeAnnouncements.
	lab
		color:
			(self model isCollapsed
				ifTrue: [ self theme taskbarItemLabelColorForCollapsed: self ]
				ifFalse: [ self theme taskbarItemLabelColorForExpanded: self ])
]

{ #category : 'drag and drop' }
TaskbarItemMorph >> mouseDown: event [
	"Set up click-or-drag handling. A short click activates the window;
	a drag beyond the threshold initiates task reordering."

	event yellowButtonPressed ifTrue: [ ^ super mouseDown: event ].
	event hand
		waitForClicksOrDrag: self
		event: event
		selectors: #( click: doubleClick: doubleClickTimeout: startDrag: )
		threshold: 5
]

{ #category : 'drag and drop' }
TaskbarItemMorph >> mouseEnterDragging: event [
	"The hand is dragging a morph over us. Show a drop indicator bar."

	| taskbar draggedTask myTask idx x |
	taskbar := self owner.
	(taskbar isKindOf: TaskbarMorph) ifFalse: [ ^ self ].
	draggedTask := event hand submorphs
		ifEmpty: [ ^ self ]
		ifNotEmpty: [ :morphs | morphs first passenger ].
	(draggedTask isKindOf: TaskbarTask) ifFalse: [ ^ self ].
	myTask := self model taskbarTask.
	myTask ifNil: [ ^ self ].
	draggedTask = myTask ifTrue: [ ^ self ].
	idx := taskbar submorphIndexOf: self.
	idx ifNil: [ ^ self ].
	x := event position x - self fullBounds left.
	x < (self width / 2)
		ifTrue: [ taskbar showDropIndicatorAfterIndex: idx - 1 ]
		ifFalse: [ taskbar showDropIndicatorAfterIndex: idx ]
]

{ #category : 'style - border' }
TaskbarItemMorph >> mouseOverBorderStyle [
	"Return the mouse over borderStyle of the receiver."

	^ self theme taskbarItemMouseOverBorderStyleFor: self
]

{ #category : 'style - filling' }
TaskbarItemMorph >> mouseOverFillStyle [
	"Return the mouse over fillStyle of the receiver."

	^ self theme taskbarItemMouseOverFillStyleFor: self
]

{ #category : 'style - border' }
TaskbarItemMorph >> normalBorderStyle [
	"Return the normal borderStyle of the receiver."

	^ self theme taskbarItemNormalBorderStyleFor: self
]

{ #category : 'style - filling' }
TaskbarItemMorph >> normalFillStyle [
	"Return the normal fillStyle of the receiver."

	^ self theme taskbarItemNormalFillStyleFor: self
]

{ #category : 'style - border' }
TaskbarItemMorph >> pressedBorderStyle [
	"Return the pressed borderStyle of the receiver."

	^ self theme taskbarItemPressedBorderStyleFor: self
]

{ #category : 'style - filling' }
TaskbarItemMorph >> pressedFillStyle [
	"Return the pressed fillStyle of the receiver."

	^ self theme taskbarItemPressedFillStyleFor: self
]

{ #category : 'style - border' }
TaskbarItemMorph >> selectedBorderStyle [
	"Return the selected borderStyle of the receiver."

	^ self theme taskbarItemSelectedBorderStyleFor: self
]

{ #category : 'style - border' }
TaskbarItemMorph >> selectedDisabledBorderStyle [
	"Return the selected disabled borderStyle of the receiver."

	^ self theme taskbarItemSelectedDisabledBorderStyleFor: self
]

{ #category : 'style - filling' }
TaskbarItemMorph >> selectedDisabledFillStyle [
	"Return the selected disabled fillStyle of the receiver."

	^ self theme taskbarItemSelectedDisabledFillStyleFor: self
]

{ #category : 'style - filling' }
TaskbarItemMorph >> selectedFillStyle [
	"Return the selected fillStyle of the receiver."

	^ self theme taskbarItemSelectedFillStyleFor: self
]

{ #category : 'style - border' }
TaskbarItemMorph >> selectedMouseOverBorderStyle [
	"Return the selected mouse over borderStyle of the receiver."

	^ self theme taskbarItemSelectedMouseOverBorderStyleFor: self
]

{ #category : 'style - filling' }
TaskbarItemMorph >> selectedMouseOverFillStyle [
	"Return the selected mouse over fillStyle of the receiver."

	^ self theme taskbarItemSelectedMouseOverFillStyleFor: self
]

{ #category : 'style - border' }
TaskbarItemMorph >> selectedPressedBorderStyle [
	"Return the selected pressed borderStyle of the receiver."

	^ self theme taskbarItemSelectedPressedBorderStyleFor: self
]

{ #category : 'style - filling' }
TaskbarItemMorph >> selectedPressedFillStyle [
	"Return the selected pressed fillStyle of the receiver."

	^ self theme taskbarItemSelectedPressedFillStyleFor: self
]

{ #category : 'drag and drop' }
TaskbarItemMorph >> startDrag: event [
	"Initiate a drag operation. Create a TransferMorph carrying the TaskbarTask."

	| taskbar task transferMorph |
	taskbar := self owner.
	taskbar ifNil: [ ^ self ].
	(taskbar isKindOf: TaskbarMorph) ifFalse: [ ^ self ].
	task := taskbar taskOf: self model.
	task ifNil: [ ^ self ].
	transferMorph := TransferMorph withPassenger: task from: self.
	transferMorph align: transferMorph center with: event position.
	event hand grabMorph: transferMorph.
	event hand releaseMouseFocus: self
]

{ #category : 'drag and drop' }
TaskbarItemMorph >> wantsDroppedMorph: aMorph event: event [
	"Accept drops only from TransferMorph carrying a TaskbarTask."

	(aMorph isKindOf: TransferMorph) ifFalse: [ ^ false ].
	^ aMorph passenger isKindOf: TaskbarTask
]

{ #category : 'menu' }
TaskbarItemMorph >> wantsYellowButtonMenu [
	^ true
]
