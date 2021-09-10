package main

import (
	"fmt"
	"os"
	"strings"
	"time"

	"github.com/Shopify/sarama"
)

var (
	user    = "token"
	apikey  = os.Getenv("APIKEY")
	brokers = os.Getenv("BROKERS")
	topic   = os.Getenv("TOPIC")
	group   = os.Getenv("GROUP")
)

func main() {
	config := sarama.NewConfig()

	config.Net.SASL.Enable = true
	config.Net.SASL.Mechanism = sarama.SASLTypePlaintext
	config.Net.SASL.User = user
	config.Net.SASL.Password = apikey

	config.Net.TLS.Enable = true

	addrs := strings.Split(brokers, ",")
	fmt.Printf("brokers: %v\n", addrs)
	client, err := sarama.NewClient(addrs, config)
	if err != nil {
		fmt.Printf("failed to create the client: %v\n", err)
		os.Exit(1)
	}
	defer client.Close()

	adminclient, err := sarama.NewClusterAdminFromClient(client)
	if err != nil {
		fmt.Printf("failed to create the admin client: %v\n", err)
		os.Exit(1)
	}
	defer adminclient.Close()

	start := time.Now()

	fmt.Printf("Describe topics...")
	topicsMetadata, err := adminclient.DescribeTopics([]string{topic})
	if err != nil {
		fmt.Printf("failed to describe topics: %v\n", err)
		os.Exit(1)
	}

	elapsed := time.Since(start)
	fmt.Printf("%s\n", elapsed.String())

	partitionMetadata := topicsMetadata[0].Partitions
	partitions := make([]int32, len(partitionMetadata))
	for i, p := range partitionMetadata {
		partitions[i] = p.ID
	}

	fmt.Printf("ListConsumerGroupOffsets...")
	start = time.Now()
	_, err = adminclient.ListConsumerGroupOffsets(group, map[string][]int32{
		topic: partitions,
	})
	if err != nil {
		fmt.Printf("failed to ListConsumerGroupOffsets: %v\n", err)
		os.Exit(1)
	}

	elapsed = time.Since(start)
	fmt.Printf("%s\n", elapsed.String())

	for i := 0; i < 1; i++ {

		fmt.Printf("GetOffsets (%d partitions)...", len(partitions))
		start = time.Now()

		// for _, partition := range partitions {
		// 	_, err := client.GetOffset(topic, partition, sarama.OffsetNewest)
		// 	if err != nil {
		// 		fmt.Printf("failed to get offset: %v\n", err)
		// 		os.Exit(1)
		// 	}
		// }
		_, err := getOffsets(client, topic, partitions, sarama.OffsetNewest)
		if err != nil {
			fmt.Printf("failed to get offset: %v\n", err)
			os.Exit(1)
		}

		elapsed = time.Since(start)
		fmt.Printf("%s\n", elapsed.String())
	}
}

func getOffsets(client sarama.Client, topic string, partitions []int32, time int64) ([]int32, error) {
	if client.Closed() {
		return nil, sarama.ErrClosedClient
	}

	offsets := make([]int32, len(partitions))

	requests := make(map[*sarama.Broker]*sarama.OffsetRequest)

	for _, partitionID := range partitions {
		broker, err := client.Leader(topic, partitionID)
		if err != nil {
			return nil, err
		}

		request, ok := requests[broker]
		if !ok {
			request = &sarama.OffsetRequest{}
			requests[broker] = request
		}

		request.Version = 1
		request.AddBlock(topic, partitionID, time, 1)
	}

	for broker, request := range requests {
		response, err := broker.GetAvailableOffsets(request)
		if err != nil {
			_ = broker.Close()
			return nil, err
		}

		for _, blocks := range response.Blocks {
			for partitionID, block := range blocks {
				if block.Err != sarama.ErrNoError {
					return nil, block.Err
				}

				fmt.Printf("offset for %d is %d\n", partitionID, block.Offset)
			}
		}
	}

	return offsets, nil
}
