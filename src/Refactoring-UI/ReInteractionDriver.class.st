"
I represent a bridge between refactoring core and UI. I am abstract class and you should use my subclasses to invoke specific refactorings.

For the flow of the refactorings through driver:

1. Driver is created and invoked through command. Command supplies it with scopes and a minimum set of inputs. It is drivers responsibility to gather all other required inputs from the user.
2. Driver should create a new instance of refactoring that it will execute later. (Note: some drivers may operate with a few refactorings, in those cases pick a default one here). Sometimes the refactoring is partially instantiated (it is not provided all the information at once) but first created then further more information is provided. For example, for renameMethod, the refactorings is created before the new name is asked to the user, so that the driver can ask the refactoring if the new name is correct. This is the job of the refactoring to do that - we should not duplicate this logic in the driver.
3. Next, driver should check applicability preconditions that are not related to user input. (For example if we want to rename a method, we should first check if the method to be renamed exist before asking user for a new name).
4. Following that, driver should gather all required inputs from the user:
  - a checkbox per each configuration that are related to the refactoring begin performed. This is where we show the user defaults that are carefully chosen so that user doesn't need to change them majority of the time. For example, for Pull Up Method refactoring here we put a checkbox that says ""Remove duplicate methods from sibling classes as well"" which is marked by default,
  - any additional info that might be required (like pick a target class or pick a new name, etc.). 5. Method refactoring here we put a checkbox that says ""Remove duplicate methods from sibling classes as well"" which is marked by default,
any additional info that might be required (like pick a target class or pick a new name, etc.).
5. Driver then passes the inputs to the refactorings and check preconditions that are related to user input (for rename method, we will check if the name is valid, if it already exists, etc.)
6. If the name is not valid, we return to step 4. and show the user error message of why the input was not valid and ask it for a new name. If the user cancels we should abort the refactoring. We are in this loop until all inputs are validated.
7. After validating user inputs, driver then checks breaking change preconditions. Based on failed preconditions driver creates a selection dialog.
7.1. If the conditions do not hold the dialog contains messages of the failed breaking change preconditions and a list of choices. Each choice is an action that can be performed on the system. Take a look at Rename Class driver and its handleBrekaingChanges method.
7.2. Based on error messages user picks action which he wants to perform, which can either go to step 8. or open some other flow depending on the selection (these flows include: opening browser of references/senders/etc.).
8. Driver executes the refactoring and previews the changes to the user (this is by default executed if the preconditions from the step 8. hold).
9. User selects which changes to apply. When confirming the selection, selected changes are performed on the image.

We also need to pay attention to create least possible amount of UI interaction.
This means that if we have to collect target class, and some configuration, we do it in one go.
Multiple dialogs are very boring and break the flow, make the process feel slow, etc.

One additional thing that is very important, we need to make sure that happy path is very fast to execute. So we should put focus on all buttons that go with happy path so that developers can act quickly and use shortcuts to perform refactorings.

Based on this we can see that each driver should have 3 types of UI interaction at maximum. Those are:
- Gather inputs and configuration,
- Handling breaking changes,
- Previewing changes.
In the future we can think of merging these. The suggestion for merging is to have options 2 and 3 merged, where we have default choice (default refactoring) that is previewed by default as well, and user can switch choices and thus change preview of the changes as well. If we manage to do that, we could even move configuration to the same window and have only two steps: 1. gather input 2. preview changes with default configuration and default choice action which user can tweak. This way the process feels more alive and is something we should strive for.


"
Class {
	#name : 'ReInteractionDriver',
	#superclass : 'Object',
	#instVars : [
		'model',
		'scopes',
		'refactoring',
		'previewPresenterClass',
		'selectDialog',
		'requestDialog',
		'informDialog',
		'stoppedBeforeApplyingRefactoring'
	],
	#category : 'Refactoring-UI-Drivers',
	#package : 'Refactoring-UI',
	#tag : 'Drivers'
}

{ #category : 'testing' }
ReInteractionDriver class >> isAbstract [

	^ self == ReInteractionDriver
]

{ #category : 'displaying' }
ReInteractionDriver class >> menuItemString [
	"Make sure that the user knows that this is a transformation by adding (T) in front of the menu item name."

	^ self refactoringClass menuItemString
]

{ #category : 'displaying' }
ReInteractionDriver class >> refactoringClass [

	self subclassResponsibility
]

{ #category : 'execution' }
ReInteractionDriver >> application [
	"For now use the singleton. Normally the application should be passed from Calypso and the command"
	
	^ StPharoApplication current

]

{ #category : 'execution' }
ReInteractionDriver >> applyChanges [

	| applied |
	applied := self openPreviewWithChanges: self changes.
	"it looks like there is a bug in Spec"
	"stoppedBeforeApplyingRefactoring := applied isCancelled not
	isCancelled returns always true so I will use it when this will be fixed in spec."
]

{ #category : 'execution' }
ReInteractionDriver >> changes [
	"Drivers should not call generateChanges of Refactoring because generateChanges is performing the preconditions and raising errors 
	The API method generateChanges is for refactoring scripting."
	
	^ self subclassResponsibility 

]

{ #category : 'private' }
ReInteractionDriver >> defaultInformDialog [

  ^ self application newInform
]

{ #category : 'configuration' }
ReInteractionDriver >> defaultRequestDialog [
	"We do not use a subclassResponsibility because all the drivers do not have to."

	^ SpRequestDialog new
]

{ #category : 'configuration' }
ReInteractionDriver >> defaultSelectDialog [
	"We do not use a subclassResponsibility because all the drivers do not have to."
	
	^ self
	
]

{ #category : 'execution' }
ReInteractionDriver >> furtherActionFor: aReport [
	
	aReport browse
]

{ #category : 'private' }
ReInteractionDriver >> informConditions: conditions [ 
	"The receiver has multiple failed applicability conditions and more than one could fail, inform all failures"

	conditions do: [ : cond | self inform: cond errorString ].
]

{ #category : 'private' }
ReInteractionDriver >> informDialog [
	"I'm hook to inject mock in tests. The driver should specialize defaultInformDialog"
	
	^ informDialog ifNil: [ informDialog := self defaultInformDialog ]
]

{ #category : 'private' }
ReInteractionDriver >> informDialog: aDialog [

	 informDialog := aDialog
]

{ #category : 'initialization' }
ReInteractionDriver >> initialize [

	super initialize.
	stoppedBeforeApplyingRefactoring := false.
	"for now unused but we should soon use it. Check applyChanges"
]

{ #category : 'accessing' }
ReInteractionDriver >> model [
	"Answer the receiver's <RBBrowserEnvironment>"

	^ model
]

{ #category : 'accessing' }
ReInteractionDriver >> model: aRBBrowserEnvironment [ 
	model := aRBBrowserEnvironment
]

{ #category : 'execution' }
ReInteractionDriver >> openPreviewWithChanges: changes [
	
	^ (self previewPresenterClass
		 changes: changes
		 scopes: scopes)
		application: self application;
		refactoring: self refactoring;
		openModal
]

{ #category : 'configuration' }
ReInteractionDriver >> previewPresenterClass [

	^ previewPresenterClass ifNil: [ previewPresenterClass := StRefactoringPreviewPresenter ] 
	
	
]

{ #category : 'configuration' }
ReInteractionDriver >> previewPresenterClass: aClass [

	 previewPresenterClass := aClass
	
	
]

{ #category : 'resources' }
ReInteractionDriver >> refactoring [
	^ refactoring
]

{ #category : 'utilities' }
ReInteractionDriver >> refactoringScopeOn: aScope [

	^ RBNamespace onEnvironment: aScope asRBEnvironment
]

{ #category : 'private' }
ReInteractionDriver >> requestDialog [
	"I'm hook for the injection of mock in tests. Subclasses should only redefine defaultRequestDialog if needed."
	
	^ requestDialog ifNil: [ requestDialog := self defaultRequestDialog ]
]

{ #category : 'accessing' }
ReInteractionDriver >> requestDialog: aStRequestDialog [

	requestDialog := aStRequestDialog
]

{ #category : 'execution' }
ReInteractionDriver >> runRefactoring [

	self subclassResponsibility
]

{ #category : 'accessing' }
ReInteractionDriver >> scopes [

	^ scopes
]

{ #category : 'accessing' }
ReInteractionDriver >> scopes: anObject [

	scopes := anObject
]

{ #category : 'configuration' }
ReInteractionDriver >> selectDialog [
	
	^ selectDialog ifNil: [ selectDialog := self defaultSelectDialog ].
	
]

{ #category : 'configuration' }
ReInteractionDriver >> selectDialog: aDialog [
	
	selectDialog := aDialog 
	
]
