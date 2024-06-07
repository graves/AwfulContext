Class {
	#name : #MarkdownFormatter,
	#superclass : #Object,
	#category : #AwfulContext
}

{ #category : #accessing }
MarkdownFormatter class >> clipClass: aClassName [
    "Copies the Markdown formatted class details to the clipboard."
    Clipboard clipboardText: (self printClass: aClassName).
]

{ #category : #accessing }
MarkdownFormatter class >> clipMethodWithClass: aClassName method: aMethodSymbol [
    "Copies the Markdown formatted method details to the clipboard."
    Clipboard clipboardText: (self printMethodWithClass: aClassName method: aMethodSymbol)
]

{ #category : #accessing }
MarkdownFormatter class >> markdownStringForClass: aClassName [
    "Generates the Markdown formatted string for the given class including class definition, instance variables, class variables, and methods."
    ^ String streamContents: [:stream |
        self printClassHeader: aClassName to: stream.
        self printClassVariables: aClassName to: stream.
        self printClassMethods: aClassName to: stream.
        self printInstanceMethods: aClassName to: stream.
    ]
]

{ #category : #accessing }
MarkdownFormatter class >> markdownStringForMethod: aMethodSymbol ofClass: aClassName [
    "Generates the Markdown formatted string for the given method, including source code, implementors, references, and examples."
    ^ String streamContents: [:stream |
        self printMethodHeader: aMethodSymbol ofClass: aClassName to: stream.
        self printMethodSource: aMethodSymbol ofClass: aClassName to: stream.
        self printMethodImplementors: aMethodSymbol ofClass: aClassName to: stream.
        self printMethodReferences: aMethodSymbol ofClass: aClassName to: stream.
        self printMethodExamples: aMethodSymbol ofClass: aClassName to: stream.
    ].
]

{ #category : #accessing }
MarkdownFormatter class >> printClass: aClassName [
	"Returns the Markdown formatted string of the class definition, instance variables, class variables, and methods."
    ^ self markdownStringForClass: aClassName.
]

{ #category : #accessing }
MarkdownFormatter class >> printClassHeader: aClassName to: stream [
    "Prints the class header details in Markdown format."
    stream
        nextPutAll: 'Here is source code and context of the Class named ', aClassName asString, ', formatted and displayed in Markdown: '; cr;
        nextPutAll: '## Class Definition'; cr; cr;
        nextPutAll: aClassName asString; cr; cr;
        nextPutAll: '## Superclass'; cr;
        nextPutAll: aClassName superclass asString; cr; cr
]

{ #category : #accessing }
MarkdownFormatter class >> printClassMethods: aClassName to: stream [
    "Prints the class methods in Markdown format."
    | categories |
    categories := aClassName class organization categories.

    stream
        nextPutAll: '## Class Methods'; cr;
        nextPutAll: 'Number of class methods: ', aClassName class selectors size asString; cr; cr.

    categories do: [:cat |
        stream nextPutAll: '### ', cat; cr.
        (aClassName class organization listAtCategoryNamed: cat) do: [:each |
            [self printMethodDetails: each ofClass: aClassName to: stream] on: Error do: [:ex |
                stream nextPutAll: '#### ', each; cr.
                stream nextPutAll: 'Error: ', ex messageText; cr; cr].
        ].
    ].
]

{ #category : #accessing }
MarkdownFormatter class >> printClassVariables: aClassName to: stream [
    "Prints the class and instance variables in Markdown format."
    | classVariables instanceVariables |
    instanceVariables := aClassName instVarNames.
    classVariables := aClassName class classPool keys.

    stream
        nextPutAll: '## Instance Variables'; cr;
        nextPutAll: 'Number of instance variables: ', instanceVariables size asString; cr; cr.

    instanceVariables do: [:each |
        stream nextPutAll: '* ', each; cr].

    stream
        nextPutAll: '## Class Variables'; cr;
        nextPutAll: 'Number of class variables: ', classVariables size asString; cr; cr.

    classVariables do: [:each |
        stream nextPutAll: '* ', each; cr].
]

{ #category : #accessing }
MarkdownFormatter class >> printInstanceMethodDetails: aMethodSymbol ofClass: aClassName to: stream [
	"Prints the instance method details in Markdown format, including references and source code."
    | method references |
    method := aClassName compiledMethodAt: aMethodSymbol ifAbsent: [nil].
    references := (aClassName allCallsOn: aMethodSymbol) size.

    stream nextPutAll: '#### ', aMethodSymbol; cr.
    stream nextPutAll: 'Number of references: ', references asString; cr.

    method ifNotNil: [
        stream nextPutAll: '```smalltalk'; cr.
        stream nextPutAll: method sourceCode; cr.
        stream nextPutAll: '```'; cr; cr.
    ] ifNil: [
        stream nextPutAll: 'Method not found or does not have source code.'; cr; cr.
    ].
]

{ #category : #accessing }
MarkdownFormatter class >> printInstanceMethods: aClassName to: stream [
    "Prints the instance methods in Markdown format."
    | categories |
    categories := aClassName organization categories.

    stream
        nextPutAll: '## Instance Methods'; cr;
        nextPutAll: 'Number of instance methods: ', aClassName selectors size asString; cr; cr.

    categories do: [:cat |
        stream nextPutAll: '### ', cat; cr.
        (aClassName organization listAtCategoryNamed: cat) do: [:each |
            [self printInstanceMethodDetails: each ofClass: aClassName to: stream] on: Error do: [:ex |
                stream nextPutAll: '#### ', each; cr.
                stream nextPutAll: 'Error: ', ex messageText; cr; cr].
        ].
    ].
]

{ #category : #accessing }
MarkdownFormatter class >> printMethodDetails: aMethodSymbol ofClass: aClassName to: stream [
 	"Prints the method details in Markdown format, including references and source code."
    | method references |
    method := aClassName class compiledMethodAt: aMethodSymbol ifAbsent: [nil].
    references := (aClassName class allCallsOn: aMethodSymbol) size.

    stream nextPutAll: '#### ', aMethodSymbol; cr.
    stream nextPutAll: 'Number of references: ', references asString; cr.

    method ifNotNil: [
        stream nextPutAll: '```smalltalk'; cr.
        stream nextPutAll: method sourceCode; cr.
        stream nextPutAll: '```'; cr; cr.
    ] ifNil: [
        stream nextPutAll: 'Method not found or does not have source code.'; cr; cr.
    ].
]

{ #category : #accessing }
MarkdownFormatter class >> printMethodExamples: aMethodSymbol ofClass: aClassName to: stream [ [
    "Prints the examples of the method in the specified class."
    | examples |
    examples := (#gtExample gtPragmas contents) select: [:method | method sourceCode includesSubstring: aMethodSymbol asString].
    examples := examples asSortedCollection: [:a :b | a sourceCode size < b sourceCode size].

    examples isEmpty ifFalse: [
        stream nextPutAll: '## Examples'; cr.
        examples do: [:each |
            stream nextPutAll: '### ', each methodClass name, '>>', each selector asString; cr.
            stream nextPutAll: 'smalltalk'; cr. 
            stream nextPutAll: each sourceCode; cr.
             stream nextPutAll: ''; cr; cr
		]
	]
].
]

{ #category : #accessing }
MarkdownFormatter class >> printMethodHeader: aMethodSymbol ofClass: aClassName to: stream [
    "Prints the method header details in Markdown format."
    stream
        nextPutAll: 'Here is source code and context of a class formatted and printed in Markdown: '; cr;
        nextPutAll: '## Class and Method Details'; cr;
        nextPutAll: '### Class: ', aClassName name; cr;
        nextPutAll: '### Method: ', aMethodSymbol asString; cr
]

{ #category : #accessing }
MarkdownFormatter class >> printMethodImplementors: aMethodSymbol ofClass: aClassName to: stream [ [
    "Prints the implementors of the method in the specified class."
    | implementors |
    implementors := aMethodSymbol gtImplementors select: [:method | method methodClass = aClassName].

    stream
        nextPutAll: '## Implementors'; cr.
    
    implementors isEmpty ifTrue: [
        stream nextPutAll: 'No implementors found for ', aMethodSymbol asString; cr
    ] ifFalse: [
        implementors do: [:method |
            stream nextPutAll: '### ', method selector asString; cr.
            stream nextPutAll: '```smalltalk'; cr.
            stream nextPutAll: method sourceCode; cr.
            stream nextPutAll: '```'; cr; cr
        ]
    ]
].
]

{ #category : #accessing }
MarkdownFormatter class >> printMethodReferences: aMethodSymbol ofClass: aClassName to: stream [ [
    "Prints the references to the method in the specified class."
    | references |
    references := (aMethodSymbol gtReferences contents) asSortedCollection: [:a :b | a sourceCode size < b sourceCode size].

    stream
        nextPutAll: '## References'; cr.
    
    references isEmpty ifTrue: [
        stream nextPutAll: 'No references found for ', aMethodSymbol asString; cr
    ] ifFalse: [
        (references first: (3 min: references size)) do: [:each |
            stream nextPutAll: '### ', each methodClass name, '>>', each selector asString; cr.
            stream nextPutAll: '```smalltalk'; cr.
            stream nextPutAll: each sourceCode; cr.
            stream nextPutAll: '```'; cr; cr
        ]
    ]
].
]

{ #category : #accessing }
MarkdownFormatter class >> printMethodSource: aMethodSymbol ofClass: aClassName to: stream [
    "Prints the source code of the method in Markdown format."
    (aClassName includesSelector: aMethodSymbol) ifTrue: [
        | method |
        method := (aClassName compiledMethodAt: aMethodSymbol ifAbsent: [nil]).
        method ifNotNil: [
            stream nextPutAll: '## Source Code'; cr.
            stream nextPutAll: '```smalltalk'; cr.
            stream nextPutAll: method sourceCode; cr.
            stream nextPutAll: '```'; cr; cr
        ] ifNil: [
            stream nextPutAll: 'Method source not found'; cr
        ]
    ] ifFalse: [
        stream nextPutAll: 'Method not found'; cr
    ]
]

{ #category : #accessing }
MarkdownFormatter class >> printMethodWithClass: aClassName method: aMethodSymbol [
    "Returns the Markdown formatted string of the method details, including source code, implementors, references, and examples."
    ^ self markdownStringForMethod: aMethodSymbol ofClass: aClassName
]
