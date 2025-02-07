Class {
	#name : #BaselineOfAwfulContext,
	#superclass : #BaselineOf,
	#category : #BaselineOfAwfulContext
}

{ #category : #loading }
BaselineOfAwfulContext class >> loadLepiter [
	IceRepository registry  
		detect: [ :aRepository |
			aRepository name = 'AwfulContext' ]
		ifFound: [ :aRepository | 
			| defaultDatabase currentProperties |
			defaultDatabase := LeDatabasesRegistry defaultLogicalDatabase.
			currentProperties := defaultDatabase properties.
			currentProperties addRegisteredDirectory: aRepository repositoryDirectory / 'lepiter'.
			defaultDatabase reload ]
		ifNone: [
			self inform: 'Repository not found.' ]
]

{ #category : #baseline }
BaselineOfAwfulContext >> baseline: spec [
	<baseline>
		^ spec for: #common do: [
			spec package: 'AwfulContext'
		]
]
