import 'package:flutter/material.dart';

class FeedPage extends StatelessWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feed', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.circle, color: Colors.grey),
            onPressed: () {},
          )
        ],
      ),
      body: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) => const FeedItem(),
      ),
    );
  }
}

class FeedItem extends StatefulWidget {
  const FeedItem({super.key});

  @override
  State<FeedItem> createState() => _FeedItemState();
}

class _FeedItemState extends State<FeedItem> {
  bool isLiked = false;
  int likeCount = 0;
  List<Map<String, dynamic>> comments = [];
  final TextEditingController _commentController = TextEditingController();
  final String username = 'Mark Jerome Santos';
  final String postImageUrl = 'https://www.mensjournal.com/.image/ar_4:3%2Cc_fill%2Ccs_srgb%2Cfl_progressive%2Cq_auto:good%2Cw_1200/MjA0NjU0OTA3MTEzMjg1MjIx/fitness-health-and-city-man-running-on-street-with-motivation-healthy-mindset-and-summer-morning-energy-for-training-urban-workout-cardio-exercise-and-runner-on-bridge-focus-on-sports-lifestyle.jpg';

  void toggleLike() {
    setState(() {
      if (isLiked) {
        likeCount--;
      } else {
        likeCount++;
      }
      isLiked = !isLiked;
    });
  }

  void toggleCommentLike(int index) {
    setState(() {
      comments[index]['isLiked'] = !(comments[index]['isLiked'] ?? false);
      if (comments[index]['isLiked']) {
        comments[index]['likes'] = (comments[index]['likes'] ?? 0) + 1;
      } else {
        comments[index]['likes'] = (comments[index]['likes'] ?? 1) - 1;
      }
    });
  }

  void openCommentsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Comments', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                SizedBox(
                  height: 200,
                  child: comments.isEmpty
                      ? const Center(child: Text('No comments yet'))
                      : ListView.builder(
                    itemCount: comments.length,
                    itemBuilder: (context, index) => ListTile(
                      leading: const CircleAvatar(
                        backgroundImage: NetworkImage('https://images.unsplash.com/photo-1535713875002-d1d0cf377fde'),
                      ),
                      title: Text(comments[index]['user'] ?? ''),
                      subtitle: Text(comments[index]['comment'] ?? ''),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              (comments[index]['isLiked'] ?? false)
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: (comments[index]['isLiked'] ?? false)
                                  ? Colors.red
                                  : Colors.black,
                            ),
                            onPressed: () {
                              setModalState(() {
                                comments[index]['isLiked'] = !(comments[index]['isLiked'] ?? false);
                                if (comments[index]['isLiked']) {
                                  comments[index]['likes'] = (comments[index]['likes'] ?? 0) + 1;
                                } else {
                                  comments[index]['likes'] = (comments[index]['likes'] ?? 1) - 1;
                                }
                              });
                            },
                          ),
                          Text('${comments[index]['likes'] ?? 0}'),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    labelText: 'Add a comment',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () {
                        if (_commentController.text.trim().isNotEmpty) {
                          setState(() { // 🔥 Main widget refresh
                            comments.add({
                              'user': username,
                              'comment': _commentController.text.trim(),
                              'likes': 0,
                              'isLiked': false,
                            });
                          });
                          setModalState(() {}); // 🔥 Also refresh bottom sheet UI
                          _commentController.clear();
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: const CircleAvatar(
            backgroundImage: NetworkImage('https://images.unsplash.com/photo-1535713875002-d1d0cf377fde'),
          ),
          title: Text(username),
          subtitle: const Text('Yogyakarta'),
          trailing: IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: NetworkImage(postImageUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            children: [
              Text('Running', style: TextStyle(fontWeight: FontWeight.bold)),
              Spacer(),
              Text('20 km | 2 hr | 40 m')
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked ? Colors.red : Colors.black,
                ),
                onPressed: toggleLike,
              ),
              Text('$likeCount'),
              IconButton(
                icon: const Icon(Icons.chat_bubble_outline),
                onPressed: openCommentsSheet,
              ),
              Text('${comments.length}'),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.bookmark_border),
                onPressed: () {},
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text('Cameron Williamson - Be Healthy'),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: Text('2 Hours ago', style: TextStyle(color: Colors.grey, fontSize: 12)),
        ),
        const Divider(),
      ],
    );
  }
}
