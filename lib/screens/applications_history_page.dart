import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'chat_page.dart';

class ApplicationsHistoryPage extends StatelessWidget {
  const ApplicationsHistoryPage({super.key});

  static const Color primaryDark =
      Color(0xFF1A2238);

  @override
  Widget build(BuildContext context) {
    final user =
        FirebaseAuth.instance.currentUser;

    ////////////////////////////////////////////////////////////////////////////
    /// USER NOT AUTHORIZED
    ////////////////////////////////////////////////////////////////////////////

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            "Необходимо войти в аккаунт",
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor:
          const Color(0xFFF4F7FA),

      ////////////////////////////////////////////////////////////////////////////
      /// APP BAR
      ////////////////////////////////////////////////////////////////////////////

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,

        title: const Text(
          "История откликов",

          style: TextStyle(
            color: primaryDark,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      ////////////////////////////////////////////////////////////////////////////
      /// BODY
      ////////////////////////////////////////////////////////////////////////////

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('applications')
            .where(
              'uid',
              isEqualTo: user.uid,
            )
            .snapshots(),

        builder: (context, snapshot) {

          ////////////////////////////////////////////////////////////////////////////
          /// LOADING
          ////////////////////////////////////////////////////////////////////////////

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          ////////////////////////////////////////////////////////////////////////////
          /// ERROR
          ////////////////////////////////////////////////////////////////////////////

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding:
                    const EdgeInsets.all(20),

                child: Text(
                  "Ошибка:\n${snapshot.error}",

                  textAlign: TextAlign.center,

                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            );
          }

          ////////////////////////////////////////////////////////////////////////////
          /// EMPTY
          ////////////////////////////////////////////////////////////////////////////

          if (!snapshot.hasData ||
              snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "Вы ещё не откликались\nна вакансии",

                textAlign: TextAlign.center,

                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            );
          }

          ////////////////////////////////////////////////////////////////////////////
          /// DOCS
          ////////////////////////////////////////////////////////////////////////////

          final docs =
              snapshot.data!.docs;

          ////////////////////////////////////////////////////////////////////////////
          /// SORT BY DATE
          ////////////////////////////////////////////////////////////////////////////

          docs.sort((a, b) {

            final aData =
                a.data()
                    as Map<String, dynamic>;

            final bData =
                b.data()
                    as Map<String, dynamic>;

            final Timestamp? aTime =
                aData['createdAt'];

            final Timestamp? bTime =
                bData['createdAt'];

            final DateTime aDate =
                aTime?.toDate() ??
                    DateTime(1970);

            final DateTime bDate =
                bTime?.toDate() ??
                    DateTime(1970);

            return bDate.compareTo(
              aDate,
            );
          });

          ////////////////////////////////////////////////////////////////////////////
          /// LIST
          ////////////////////////////////////////////////////////////////////////////

          return ListView.builder(
            padding:
                const EdgeInsets.all(12),

            itemCount: docs.length,

            itemBuilder:
                (context, index) {

              final doc = docs[index];

              final data =
                  doc.data()
                      as Map<String, dynamic>;

              return _ApplicationCard(
                data: data,
                documentId: doc.id,
              );
            },
          );
        },
      ),
    );
  }
}

////////////////////////////////////////////////////////////////////////////////
/// APPLICATION CARD
////////////////////////////////////////////////////////////////////////////////

class _ApplicationCard
    extends StatelessWidget {

  final Map<String, dynamic> data;

  final String documentId;

  const _ApplicationCard({
    required this.data,
    required this.documentId,
  });

  @override
  Widget build(BuildContext context) {

    ////////////////////////////////////////////////////////////////////////////
    /// STATUS
    ////////////////////////////////////////////////////////////////////////////

    final String status =
        (data['status'] ?? 'sent')
            .toString();

    Color statusColor;
    String statusText;

    switch (status) {

      case 'accepted':
        statusColor = Colors.green;
        statusText = "Принят";
        break;

      case 'rejected':
        statusColor = Colors.red;
        statusText = "Отклонён";
        break;

      case 'seen':
        statusColor = Colors.orange;
        statusText = "Просмотрен";
        break;

      default:
        statusColor = Colors.blue;
        statusText = "Отправлен";
    }

    ////////////////////////////////////////////////////////////////////////////
    /// DATE
    ////////////////////////////////////////////////////////////////////////////

    final Timestamp? ts =
        data['createdAt'];

    final String dateText =
        ts != null
            ? ts
                .toDate()
                .toString()
                .substring(0, 16)
            : "—";

    ////////////////////////////////////////////////////////////////////////////
    /// CHAT ID
    ////////////////////////////////////////////////////////////////////////////

    final String? chatId =
        data['chatId'];

    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 12,
      ),

      padding:
          const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(
          16,
        ),

        boxShadow: [

          BoxShadow(
            color: Colors.black
                .withOpacity(0.03),

            blurRadius: 10,

            offset:
                const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          ////////////////////////////////////////////////////////////////////////////
          /// TITLE
          ////////////////////////////////////////////////////////////////////////////

          Text(
            data['jobTitle'] ??
                "Вакансия",

            style: const TextStyle(
              fontSize: 17,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          ////////////////////////////////////////////////////////////////////////////
          /// MESSAGE
          ////////////////////////////////////////////////////////////////////////////

          Text(
            "Сообщение: ${data['message'] ?? '—'}",

            maxLines: 2,

            overflow:
                TextOverflow.ellipsis,

            style: TextStyle(
              color: Colors
                  .grey.shade700,
            ),
          ),

          const SizedBox(height: 14),

          ////////////////////////////////////////////////////////////////////////////
          /// STATUS + DATE
          ////////////////////////////////////////////////////////////////////////////

          Row(
            mainAxisAlignment:
                MainAxisAlignment
                    .spaceBetween,

            children: [

              Container(
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),

                decoration:
                    BoxDecoration(
                  color: statusColor
                      .withOpacity(
                    0.15,
                  ),

                  borderRadius:
                      BorderRadius
                          .circular(
                    20,
                  ),
                ),

                child: Text(
                  statusText,

                  style: TextStyle(
                    color:
                        statusColor,

                    fontWeight:
                        FontWeight
                            .w600,
                  ),
                ),
              ),

              Text(
                dateText,

                style:
                    const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          ////////////////////////////////////////////////////////////////////////////
          /// BUTTONS
          ////////////////////////////////////////////////////////////////////////////

          Row(
            children: [

              ////////////////////////////////////////////////////////////////////////////
              /// OPEN CHAT
              ////////////////////////////////////////////////////////////////////////////

              if (chatId != null &&
                  chatId.isNotEmpty)

                ElevatedButton.icon(
                  onPressed: () {

                    Navigator.push(
                      context,

                      MaterialPageRoute(
                        builder: (_) =>
                            ChatPage(
                          chatId: chatId,
                        ),
                      ),
                    );
                  },

                  style:
                      ElevatedButton
                          .styleFrom(
                    backgroundColor:
                        const Color(
                      0xFF1A2238,
                    ),

                    foregroundColor:
                        Colors.white,
                  ),

                  icon: const Icon(
                    Icons.chat_bubble,
                    size: 18,
                  ),

                  label: const Text(
                    "Чат",
                  ),
                ),

              const SizedBox(width: 10),

              ////////////////////////////////////////////////////////////////////////////
              /// DELETE
              ////////////////////////////////////////////////////////////////////////////

              TextButton.icon(
                onPressed: () async {

                  try {

                    await FirebaseFirestore
                        .instance
                        .collection(
                            'applications')
                        .doc(documentId)
                        .delete();

                    if (context.mounted) {

                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Отклик удалён",
                          ),
                        ),
                      );
                    }

                  } catch (e) {

                    if (context.mounted) {

                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Ошибка: $e",
                          ),
                        ),
                      );
                    }
                  }
                },

                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                ),

                label: const Text(
                  "Удалить",

                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}