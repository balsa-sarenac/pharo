"
I manage the settings for Shout.

This includes:
  - Turning syntax highlighting on / off
  - Selecting a predefined style
  - Editing the custom style table
"
Class {
	#name : 'SHPreferences',
	#superclass : 'Object',
	#classInstVars : [
		'enabled',
		'activeStyleTable',
		'syntaxHighlightingEnabled'
	],
	#category : 'Shout-Styling',
	#package : 'Shout',
	#tag : 'Styling'
}

{ #category : 'accessing' }
SHPreferences class >> activeStyleTable [

	^ activeStyleTable ifNil: [
			  activeStyleTable := 'Default'.
			  activeStyleTable ]
]

{ #category : 'accessing' }
SHPreferences class >> activeStyleTable: aStyleTableName [
	"TODO: Check for validity of style table name"

	(Pragma allNamed: #styleTable: in: SHRBTextStyler class)
		detect: [ :pragma | (pragma argumentAt: 1) = aStyleTableName ]
		ifFound: [ :pragma |
				self styleTable:
					(SHRBTextStyler styleTableNamed: aStyleTableName) ]
		ifNone: [ "ignore" ].
	'Custom' = aStyleTableName ifTrue: [
		self styleTable: SHCustomStyle styleTable ].
	'Default' = aStyleTableName ifTrue: [
			self styleTable:
				(SHRBTextStyler perform: Smalltalk ui theme shStyleTableName) ].
	activeStyleTable := aStyleTableName.
]

{ #category : 'updating' }
SHPreferences class >> cutomStyleChanged [

	activeStyleTable = 'Custom' ifTrue: [
		self styleTable: SHCustomStyle styleTable ]
]

{ #category : 'reflective operations' }
SHPreferences class >> doesNotUnderstand: aMessage [
	"Handles messages of the form #defaultStyle or #argumentStyle: "

	(aMessage selector endsWith: 'Style') ifTrue: [
			^ SHCustomStyleElement group:
				  (aMessage selector withoutSuffix: 'Style') asSymbol ].
	(aMessage selector endsWith: 'Style:') ifTrue: [
		| style |
		style := aMessage argument.
		(SHCustomStyleElement group: (style at: #group))
			color: (style at: #color) ;
			emphasis: (style at: #emphasis).
		^ self ].
	^ super doesNotUnderstand: aMessage
]

{ #category : 'accessing - style defaults' }
SHPreferences class >> defaultSyntaxStyle [

	^ SHStyleElement tokens: #(#return #blockArgColon #parenthesis #parenthesis1 #parenthesis2 #parenthesis3 #parenthesis4 #parenthesis5 #parenthesis6 #parenthesis7 #block #block1 #block2 #block3 #block4 #block5 #block6 #block7 #byteArrayStart #byteArrayEnd #byteArrayStart1 #byteArrayEnd1 #brace #brace1 #brace2 #brace3 #brace4 #brace5 #brace6 #brace7 #cascadeSeparator #statementSeparator #methodTempBar #blockTempBar #blockArgsBar)
]

{ #category : 'accessing - style defaults' }
SHPreferences class >> defaultVariableStyle [

	^ SHStyleElement 
		color: (Color r: 0.0 g: 0.0 b: 0.5004887585532747 alpha: 1.0) 
		tokens: #(#blockTempVar #blockPatternTempVar #tempVar #patternTempVar #incompleteIdentifier)
]

{ #category : 'accessing' }
SHPreferences class >> enabled [

	^ syntaxHighlightingEnabled ifNil: [ ^ true ]
]

{ #category : 'accessing' }
SHPreferences class >> enabled: aBoolean [

	syntaxHighlightingEnabled := aBoolean.
	self informUI
]

{ #category : 'private' }
SHPreferences class >> getStateOfStyleTableNamed: aStyleTableName [

	^ aStyleTableName = self activeStyleTable
]

{ #category : 'private' }
SHPreferences class >> informUI [

	self currentWorld themeChanged
]

{ #category : 'initialization' }
SHPreferences class >> setStyleTableNamed: styleTableName [
	"TODO"

	styleTableName = #Custom ifTrue: [ "TODO" ^ self ].
	styleTableName = #Default ifTrue: [ "TODO" ^ self ].

	self styleTable: (SHRBTextStyler styleTableNamed: styleTableName)
]

{ #category : 'settings' }
SHPreferences class >> settingsOn: aBuilder [
	"TODO: the currently selected theme has to be saved to settings. Replace dialog with actual value"

	<systemsettings>
	(aBuilder group: 'Syntax Highlighting')
		parentName: #codeBrowsing;
		target: self;
		iconName: #smallConfiguration;
		noOrdering;
		with: [
				(aBuilder setting: 'Enable Syntax Highlighting')
					target: self;
					default: true;
					selector: #enabled;
					description:
						'Syntax Highlighting As You Type: Enable syntax highlighting in browsers, debuggers and workspaces and set patterns style.'.
				(aBuilder setting: #formatIncompleteIdentifiers)
					target: SHRBTextStyler;
					default: false;
					label: 'Format Incomplete Identifiers';
					parentName: #'Syntax Highlighting';
					description:
						'If the code highlighter tryies to format incomplete identifiers and selectors or not. This is not recommended for big images, as it traverse all the image to get the information'.
				(aBuilder pickOne: #activeStyleTable)
					label: 'Predefined styles';
					target: self;
					domainValues: self styleTableNames;
					default: 'Default'.
				(aBuilder group: #'Edit Custom Style')
					dialog: [
							Smalltalk ui theme
								newButtonIn: self
								for: SHCustomStyle 
								getState: nil
								action: #copyFromCurrentStyle
								arguments: nil
								getEnabled: nil
								label: 'Copy from current style'
								help:
									'Initialize custom style to colors of the currently selected them' ];
					with: [
							SHCustomStyle groups keysAndValuesDo: [ :group :info |
										(aBuilder setting: group , #Style)
											target: self;
											label: (info at: #label);
											description: (info at: #description ifAbsent: [ '' ]) ] ] ]
]

{ #category : 'private' }
SHPreferences class >> styleTable: anArray [
	"TODO: Implement a `syntaxHighlightChanged` event instead of `themeChanged`"

	SHRBTextStyler styleTable: anArray.
	self informUI
]

{ #category : 'accessing' }
SHPreferences class >> styleTableNames [

	^ { 'Custom'. 'Default' }
	  , ((Pragma allNamed: #styleTable: in: SHRBTextStyler class) collect: [:pragma | pragma argumentAt: 1])
]

{ #category : 'updating' }
SHPreferences class >> themeChanged [

	activeStyleTable = 'Default' ifTrue: [ self activeStyleTable: 'Default' ]
]
