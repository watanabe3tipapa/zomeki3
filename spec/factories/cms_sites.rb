FactoryGirl.define do
  factory :cms_site, class: 'Cms::Site' do
    state 'public'
    mobile_full_uri ''
    related_site nil
    map_key nil
    portal_group_state 'visible'
    portal_group_id nil
    portal_category_ids nil
    portal_business_ids nil
    portal_attribute_ids nil
    portal_area_ids nil
    body ''
    site_image_id nil
    og_type ''
    og_title ''
    og_description ''
    og_image ''
    smart_phone_publication 'no'
    spp_target 'only_top'
    google_map_api_key ''
    admin_full_uri ''

    trait :first do
      id 1
      created_at '2016-11-01 12:03:04'
      updated_at '2016-11-01 12:03:04'
      name 'ひとつめのサイト'
      full_uri 'http://first.example.com/'
      node_id 100
    end
  end

  factory :cms_site_first_example_com, :class => 'Cms::Site' do
    id 1
# TODO: 自動採番を考慮する
    unid 10
    state 'public'
    created_at '2012-06-01 12:01:02'
    updated_at '2012-06-01 12:01:02'
    name 'ひとつめのサイト'
    full_uri 'http://first.example.com:3000/'
    mobile_full_uri ''
# TODO: 自動採番を考慮する
    node_id 100
    related_site ''
    map_key nil
    portal_group_id nil
    portal_category_ids nil
    portal_business_ids nil
    portal_attribute_ids nil
    portal_area_ids nil
    body ''
    site_image_id nil
  end

  factory :cms_site_second_example_com, :class => 'Cms::Site' do
    id 2
# TODO: 自動採番を考慮する
    unid 20
    state 'public'
    created_at '2012-06-01 12:02:03'
    updated_at '2012-06-01 12:02:03'
    name 'ふたつめのサイト'
    full_uri 'http://second.example.com:3000/'
    mobile_full_uri ''
# TODO: 自動採番を考慮する
    node_id 200
    related_site ''
    map_key nil
    portal_group_id nil
    portal_category_ids nil
    portal_business_ids nil
    portal_attribute_ids nil
    portal_area_ids nil
    body ''
    site_image_id nil
  end

  factory :cms_site_third_example_com, :class => 'Cms::Site' do
    id 3
# TODO: 自動採番を考慮する
    unid 30
    state 'public'
    created_at '2012-06-01 12:03:04'
    updated_at '2012-06-01 12:03:04'
    name 'みっつめのサイト'
    full_uri 'http://third.example.com:3000/'
    mobile_full_uri ''
# TODO: 自動採番を考慮する
    node_id 300
    related_site ''
    map_key nil
    portal_group_id nil
    portal_category_ids nil
    portal_business_ids nil
    portal_attribute_ids nil
    portal_area_ids nil
    body ''
    site_image_id nil
  end

  factory :cms_site_cms_example_com, :class => 'Cms::Site' do
    id 4
    unid 40
    state 'public'
    created_at '2014-03-01 17:16:02'
    updated_at '2014-03-01 17:16:02'
    name 'ぞめき'
    full_uri 'http://cms.example.com/'
    mobile_full_uri ''
    node_id 1
    related_site ''
    map_key nil
    portal_group_id nil
    portal_category_ids nil
    portal_business_ids nil
    portal_attribute_ids nil
    portal_area_ids nil
    body ''
    site_image_id nil
  end
end
