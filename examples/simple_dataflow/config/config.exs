import Config

config :pratipad,
  dataflow: SimpleDataflow.Dataflow,
  forward: [
    producer: [
      module:
        {OffBroadwayOtpDistribution.Producer,
         [
           mode: :push,
           receiver: [
             name: :pratipad_receiver_forward
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
  backward: [
    producer: [
      module:
        {OffBroadwayOtpDistribution.Producer,
         [
           mode: :push,
           receiver: [
             name: :pratipad_receiver_backward
           ]
         ]}
    ],
    processors: [
      default: [concurrency: 1]
    ],
    batchers: [
      default: [concurrency: 1, batch_size: 1]
    ]
  ]
