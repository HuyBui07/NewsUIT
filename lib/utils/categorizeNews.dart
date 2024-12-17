List<String> categorizeNew(String title) {
    // Từ khóa theo từng loại tag
    Map<String, List<String>> keywordTags = {
      'Học vụ': ['lịch thi', 'kế hoạch', 'học phí'],
      'Sự kiện': ['khóa học', 'sự kiện', 'lễ hội'],
      'Thông báo': ['thông báo', 'cảnh báo'],
      'Tuyển dụng': ['tuyển dụng', 'thực tập', 'tuyển'],
    };

    List<String> tags = [];

    // Quét title và thêm tag tương ứng
    keywordTags.forEach((tag, keywords) {
      for (var keyword in keywords) {
        if (title.toLowerCase().contains(keyword.toLowerCase())) {
          tags.add(tag);
          break; // Ngừng sau khi tìm thấy từ khóa để tránh trùng lặp tag
        }
      }
    });

    if (tags.isEmpty) {
      tags.add('Khác');
    }

    return tags;
  }