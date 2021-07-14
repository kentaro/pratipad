import Config

config :pratipad,
  dataflow: SimpleDataflow.Dataflow,
  forward: [
    input: [
      producer: [
        module:
          {OffBroadwayOtpDistribution.Producer,
            [
           mode: :push,
           receiver: [
             name: :pratipad_forwarder_input
           ]
         ]}
      ],
      processors: [
        default: [concurrency: 1]
      ],
      batchers: [
        default: [concurrency: 1, batch_size: 3]
      ]
    ],
    output: [
      name: :pratipad_forwarder_output
    ]
  ],
  backward: [
    input: [
      producer: [
        module:
          {OffBroadwayOtpDistribution.Producer,
            [
              mode: :push,
              receiver: [
              name: :pratipad_backwarder_input
             ]
           ]}
      ],
      processors: [
        default: [concurrency: 1]
      ],
      batchers: [
        default: [concurrency: 1, batch_size: 1]
      ]
    ],
    output: [
      name: :pratipad_backwarder_output
    ]
  ]
