import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'global.dart';
// A widget that displays MQTT data from Firestore in a list view
class FirestoreExample extends StatelessWidget {
  // Reference to the 'mqtt_data' collection in Firestore
  final CollectionReference mqttData =
      FirebaseFirestore.instance.collection('mqtt_data');

  // Constructor with optional key parameter for widget identification
  FirestoreExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // App bar with title
      appBar: AppBar(title: const Text('MQTT Data from Firestore')),

      // Main content body
      body: StreamBuilder<QuerySnapshot>(
        // Stream that listens to real-time updates from the Firestore collection
        stream: mqttData.snapshots(),

        // Builder function that constructs the UI based on the stream state
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          // Error handling: Show error message if something went wrong
          if (streamSnapshot.hasError) {
            return Center(child: Text('Error: ${streamSnapshot.error}'));
          }

          // Loading state: Show progress indicator while waiting for data
          if (streamSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Empty state: Show message if no data is available
          if (!streamSnapshot.hasData || streamSnapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No data available'));
          }

          // Main data display: ListView that shows all documents
          return ListView.builder(
            // Number of items in the list (equal to number of documents)
            itemCount: streamSnapshot.data!.docs.length,

            // Builder for each list item
            itemBuilder: (context, index) {
              // Get the document at current index
              final document = streamSnapshot.data!.docs[index];

              // Cast the document data to a Map
              final data = document.data() as Map<String, dynamic>;

              // Check if document contains a 'values' array (for MQTT data)
              if (data.containsKey('values')) {
                // Get the values array and cast it to List<dynamic>
                final values = data['values'] as List<dynamic>;

                // Return a Column with multiple Cards (one for each value in array)
                return Column(
                  children: values.map((value) {
                    // Cast each value to a Map
                    final valueMap = value as Map<String, dynamic>;
                    
                    // Create a Card for each MQTT data point
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        title: Text('ID: ${valueMap['id']}'), // Device ID
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Value: ${valueMap['v']}'), // MQTT value
                            Text('Quality: ${valueMap['q']}'), // Quality flag
                            Text('Timestamp: ${valueMap['t']}'),
                            // Timestamp
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              } else {
                

                // For documents without 'values' field, show basic document info
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text('Document ID: ${document.id}'),
                    subtitle: Text('temp:$globalTemp'),
                  ),
                );
              }
              
            },  
          );
        },
      ),
    );
  }
}
