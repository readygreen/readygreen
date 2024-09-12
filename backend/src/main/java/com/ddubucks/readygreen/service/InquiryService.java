//package com.ddubucks.readygreen.service;
//
//import com.ddubucks.readygreen.model.Inquiry;
////import com.ddubucks.readygreen.repository.MemberRepository;
//import com.ddubucks.readygreen.repository.InquiryRepository;
//import lombok.RequiredArgsConstructor;
//import org.springframework.stereotype.Service;
//
//import java.util.List;
//
//@Service
//@RequiredArgsConstructor
//public class InquiryService {
//
//    private final InquiryRepository inquiryRepository;
////    private final MemberRepository memberRepository;
//
//    public void answerInquiry(Long inquiryId, String answer) {
//        Inquiry inquiry = inquiryRepository.findById(inquiryId)
//                .orElseThrow(() -> new IllegalArgumentException("Inquiry not found"));
//        inquiry.setAnswer(answer);
//        inquiry.setAnswered(true);
//        inquiryRepository.save(inquiry);
//    }
//
//    public List<Inquiry> getAllInquiries() {
//        return inquiryRepository.findAll();
//    }
//}
